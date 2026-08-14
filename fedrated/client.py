"""
client.py  —  AgroSentinel AI  Federated Farm Node Client
==========================================================
Fixed for Windows (no symlinks) + Flower 1.33.0.
Loads images directly from original data folders — no temp directory copy.

Each node trains only on its assigned crops, simulating
a real farm that only has data from its own fields.

Run standalone:
    python client.py --node-id 1
    python client.py --node-id 2
    python client.py --node-id 3

Or let simulate.py start all 3 automatically.
"""

import os
import sys
import argparse
import numpy as np
import tensorflow as tf
import flwr as fl
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from typing import Dict, List, Tuple

_HERE      = os.path.dirname(os.path.abspath(__file__))
MODEL_PATH = os.path.join(_HERE, "..", "models", "crop_model.h5")
DATA_DIR   = os.path.join(_HERE, "..", "models", "data")

IMG_SIZE     = (224, 224)
BATCH_SIZE   = 16
LOCAL_EPOCHS = 2
SERVER_ADDRESS = "127.0.0.1:8080"

# Each node gets specific crops — simulates different farm types
NODE_CROP_MAP = {
    1: ["Corn (Maize)"],
    2: ["Rice"],
    3: ["Potato", "Tomato"],
}


def load_node_data(node_id: int, split: str):
    """
    Load images directly from the original data folders for this node's crops.
    No temp directories, no symlinks — Windows compatible.

    Returns list of (image_array, label_index) tuples.
    """
    crops        = NODE_CROP_MAP.get(node_id, [])
    all_images   = []
    all_labels   = []
    class_names  = []

    # First pass — collect all class names for this node
    for crop in crops:
        split_path = os.path.join(DATA_DIR, crop, split)
        if not os.path.isdir(split_path):
            split_path = os.path.join(DATA_DIR, crop, split.lower())
        if not os.path.isdir(split_path):
            continue
        for disease in sorted(os.listdir(split_path)):
            if os.path.isdir(os.path.join(split_path, disease)):
                class_names.append(f"{crop}__{disease}")

    if not class_names:
        return None, None, 0, []

    cls_to_idx = {c: i for i, c in enumerate(class_names)}
    num_classes = len(class_names)

    # Second pass — load images
    from PIL import Image as PILImage
    import io

    total = 0
    for crop in crops:
        split_path = os.path.join(DATA_DIR, crop, split)
        if not os.path.isdir(split_path):
            split_path = os.path.join(DATA_DIR, crop, split.lower())
        if not os.path.isdir(split_path):
            continue

        for disease in sorted(os.listdir(split_path)):
            disease_path = os.path.join(split_path, disease)
            if not os.path.isdir(disease_path):
                continue

            class_key = f"{crop}__{disease}"
            label_idx = cls_to_idx.get(class_key, 0)

            imgs = [
                f for f in os.listdir(disease_path)
                if f.lower().endswith(('.jpg', '.jpeg', '.png'))
            ]

            # Limit per class to keep memory manageable
            imgs = imgs[:100]

            for img_name in imgs:
                img_path = os.path.join(disease_path, img_name)
                try:
                    img = PILImage.open(img_path).convert("RGB")
                    img = img.resize(IMG_SIZE, PILImage.LANCZOS)
                    arr = np.array(img, dtype=np.float32)  # no /255 for EfficientNet
                    all_images.append(arr)
                    all_labels.append(label_idx)
                    total += 1
                except Exception:
                    continue

    print(f"    Node {node_id} [{split}]: {total} images, "
          f"{num_classes} classes ({', '.join(crops)})")

    if not all_images:
        return None, None, 0, class_names

    X = np.array(all_images, dtype=np.float32)  # (N, 224, 224, 3)
    y = tf.keras.utils.to_categorical(all_labels, num_classes)  # (N, num_classes)

    return X, y, total, class_names


class AgroSentinelClient(fl.client.NumPyClient):
    """
    Flower client — represents one farm node.
    Trains locally on its own crop data, shares only weights.
    """

    def __init__(self, node_id: int):
        self.node_id = node_id
        self.crops   = NODE_CROP_MAP.get(node_id, [])

        print(f"\n   Farm Node {node_id} initialising...")
        print(f"     Crops : {', '.join(self.crops)}")
        print(f"     Loading model...")

        self.model = tf.keras.models.load_model(MODEL_PATH)
        self.model.compile(
            optimizer=tf.keras.optimizers.Adam(1e-4),
            loss="categorical_crossentropy",
            metrics=["accuracy"],
        )

        # Load local data into memory
        print(f"     Loading local training data...")
        self.X_train, self.y_train, self.n_train, self.classes = \
            load_node_data(node_id, "Train")

        print(f"     Loading local validation data...")
        self.X_val, self.y_val, self.n_val, _ = \
            load_node_data(node_id, "Val")

        # Pad labels to 16 classes if node has fewer
        if self.y_train is not None and self.y_train.shape[1] < 16:
            pad = 16 - self.y_train.shape[1]
            self.y_train = np.pad(self.y_train, ((0, 0), (0, pad)))
            if self.y_val is not None:
                self.y_val = np.pad(self.y_val, ((0, 0), (0, pad)))

        print(f"   Node {node_id} ready — {self.n_train} training samples")

    def get_parameters(self, config):
        return self.model.get_weights()

    def fit(self, parameters, config):
        """Receive global weights, train locally, return updated weights."""
        self.model.set_weights(parameters)

        print(f"\n   Node {self.node_id} — local training")
        print(f"     Epochs: {LOCAL_EPOCHS} | Samples: {self.n_train}")
        print(f"     Raw images NOT shared — only weights will be sent")

        if self.X_train is None or self.n_train == 0:
            return self.model.get_weights(), 0, {}

        history = self.model.fit(
            self.X_train, self.y_train,
            epochs=LOCAL_EPOCHS,
            batch_size=BATCH_SIZE,
            verbose=1,
        )

        acc = float(history.history["accuracy"][-1])
        print(f"   Node {self.node_id} local accuracy: {acc*100:.1f}%")
        print(f"     Sending weights to server...")

        return self.model.get_weights(), self.n_train, {"accuracy": acc}

    def evaluate(self, parameters, config):
        """Evaluate global model on local validation data."""
        self.model.set_weights(parameters)

        if self.X_val is None or self.n_val == 0:
            return 0.0, 0, {}

        loss, acc = self.model.evaluate(
            self.X_val, self.y_val,
            batch_size=BATCH_SIZE,
            verbose=0,
        )
        print(f"   Node {self.node_id} val accuracy: {acc*100:.1f}%")
        return float(loss), self.n_val, {"accuracy": float(acc)}


def start_client(node_id: int):
    print(f"\n  Connecting Node {node_id} → {SERVER_ADDRESS}")
    client = AgroSentinelClient(node_id)
    fl.client.start_numpy_client(
        server_address=SERVER_ADDRESS,
        client=client,
    )


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--node-id", type=int, default=1, choices=[1, 2, 3])
    args = parser.parse_args()
    start_client(args.node_id)