"""
Run from the federated/ folder via simulate.py, or one node at a time:
    python client.py --node-id 1
"""

import os
import json
import random
import argparse
import numpy as np
import tensorflow as tf
import flwr as fl
from PIL import Image as PILImage

_HERE       = os.path.dirname(os.path.abspath(__file__))
MODEL_PATH  = os.path.join(_HERE, "..", "models", "crop_model.h5")
LABELS_PATH = os.path.join(_HERE, "..", "models", "labels.json")
DATA_DIR    = os.path.join(_HERE, "..", "models", "data")

IMG_SIZE       = (224, 224)
BATCH_SIZE     = 16
LOCAL_EPOCHS   = 2
MAX_PER_CLASS  = 100          # per class, per node (keeps RAM and time low)
SERVER_ADDRESS = "127.0.0.1:8080"
IMG_EXT        = (".jpg", ".jpeg", ".png", ".bmp", ".tif", ".tiff")

NODE_CROP_MAP = {
    1: ["Corn (Maize)"],
    2: ["Rice"],
    3: ["Potato", "Tomato"],
}


def load_global_labels():
    """labels.json: {"0": "Corn (Maize)__Cercospora Leaf Spot", ...}"""
    with open(LABELS_PATH) as f:
        labels = json.load(f)
    name_to_idx = {name.lower(): int(idx) for idx, name in labels.items()}
    return name_to_idx, len(labels)


def _split_dir(crop, split):
    for name in (split, split.lower(), split.capitalize()):
        path = os.path.join(DATA_DIR, crop, name)
        if os.path.isdir(path):
            return path
    return None


def load_node_data(node_id, split, name_to_idx, num_classes):
    """Load this node's images with GLOBAL one-hot labels (16 columns)."""
    rng = random.Random(1000 + node_id)
    images, labels, used = [], [], set()

    for crop in NODE_CROP_MAP[node_id]:
        split_path = _split_dir(crop, split)
        if split_path is None:
            print(f"    ! {crop}/{split} not found - skipped")
            continue

        for disease in sorted(os.listdir(split_path)):
            d_path = os.path.join(split_path, disease)
            if not os.path.isdir(d_path):
                continue

            idx = name_to_idx.get(f"{crop}__{disease}".lower())
            if idx is None:
                print(f"    ! cannot map '{crop}__{disease}' to labels.json - skipped")
                continue

            files = [f for f in os.listdir(d_path) if f.lower().endswith(IMG_EXT)]
            rng.shuffle(files)
            for fname in files[:MAX_PER_CLASS]:
                try:
                    img = (PILImage.open(os.path.join(d_path, fname))
                           .convert("RGB").resize(IMG_SIZE, PILImage.LANCZOS))
                except Exception:
                    continue
                images.append(np.asarray(img, dtype=np.float32))  # raw 0-255
                labels.append(idx)
                used.add(idx)

    if not images:
        return None, None, 0, []

    X = np.stack(images)
    y = tf.keras.utils.to_categorical(labels, num_classes)
    print(f"    Node {node_id} [{split}]: {len(images)} images | "
          f"global class indices {sorted(used)}")
    return X, y, len(images), sorted(used)


class AgroSentinelClient(fl.client.NumPyClient):
    """One farm node: trains locally, shares only weights."""

    def __init__(self, node_id: int):
        self.node_id = node_id
        self.crops   = NODE_CROP_MAP[node_id]
        print(f"\n  Farm Node {node_id} initialising ({', '.join(self.crops)})")

        name_to_idx, num_classes = load_global_labels()

        self.model = tf.keras.models.load_model(MODEL_PATH)
        self.model.compile(
            optimizer=tf.keras.optimizers.Adam(1e-4),
            loss="categorical_crossentropy",
            metrics=["accuracy"],
        )

        self.X_train, self.y_train, self.n_train, _ = load_node_data(
            node_id, "Train", name_to_idx, num_classes)
        self.X_val, self.y_val, self.n_val, _ = load_node_data(
            node_id, "Val", name_to_idx, num_classes)

        print(f"  Node {node_id} ready - {self.n_train} train / {self.n_val} val images")

    def get_parameters(self, config):
        return self.model.get_weights()

    def fit(self, parameters, config):
        self.model.set_weights(parameters)
        print(f"\n  Node {self.node_id} - local training "
              f"({LOCAL_EPOCHS} epochs, {self.n_train} images; images stay local)")

        if self.X_train is None or self.n_train == 0:
            return self.model.get_weights(), 0, {}

        history = self.model.fit(
            self.X_train, self.y_train,
            epochs=LOCAL_EPOCHS, batch_size=BATCH_SIZE,
            shuffle=True, verbose=1,
        )
        acc = float(history.history["accuracy"][-1])
        print(f"  Node {self.node_id} local accuracy: {acc * 100:.1f}% - sending weights")
        return self.model.get_weights(), self.n_train, {"accuracy": acc}

    def evaluate(self, parameters, config):
        self.model.set_weights(parameters)
        if self.X_val is None or self.n_val == 0:
            return 0.0, 0, {}
        loss, acc = self.model.evaluate(
            self.X_val, self.y_val, batch_size=BATCH_SIZE, verbose=0)
        print(f"  Node {self.node_id} val accuracy on global model: {acc * 100:.1f}%")
        return float(loss), self.n_val, {"accuracy": float(acc)}


def start_client(node_id: int):
    print(f"\n  Connecting Node {node_id} -> {SERVER_ADDRESS}")
    client = AgroSentinelClient(node_id)
    fl.client.start_numpy_client(server_address=SERVER_ADDRESS, client=client)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--node-id", type=int, default=1, choices=[1, 2, 3])
    start_client(parser.parse_args().node_id)