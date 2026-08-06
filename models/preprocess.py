"""
preprocess.py — AgroSentinel AI
================================
Loads images from your pre-split Train/ Val/ Test/ folder structure.

Run this file directly to verify your dataset:
    cd "R:\\Major project\\AgroSentinel AI\\models"
    python preprocess.py
"""

import os
import json
import numpy as np
import tensorflow as tf
from tensorflow.keras.preprocessing.image import ImageDataGenerator

# ── CONFIG ────────────────────────────────────────────────────────────────────
IMG_SIZE   = (224, 224)   # MobileNetV2 input size
BATCH_SIZE = 32
SEED       = 42

# Always resolve data path relative to THIS file's location
# so it works whether you run from models/ or from the project root
_THIS_DIR = os.path.dirname(os.path.abspath(__file__))
DATA_DIR  = os.path.join(_THIS_DIR, "data")

# Exact folder names as they appear on your disk
CROP_FOLDERS = [
    "Corn (Maize)",
    "Potato",
    "Tomato",
]


def get_all_class_names(split: str = "Train") -> list:
    """
    Scans the data directory and returns a sorted list of all class names,
    prefixed with their crop name to avoid collisions.
    e.g. ["Corn (Maize)__Cercospora Leaf Spot", "Potato__Early Blight", ...]
    """
    class_names = []
    for crop in CROP_FOLDERS:
        split_path = os.path.join(DATA_DIR, crop, split)
        if not os.path.isdir(split_path):
            print(f"  ⚠️  Missing: {split_path}")
            continue
        for cls in sorted(os.listdir(split_path)):
            if os.path.isdir(os.path.join(split_path, cls)):
                class_names.append(f"{crop}__{cls}")
    return class_names


def get_unified_dataset(split: str, augment: bool = False):
    """
    Builds a tf.data.Dataset merging all three crops for a given split.

    Args:
        split   : "Train", "Val", or "Test"
        augment : True only for training split

    Returns:
        dataset      : tf.data.Dataset yielding (image_batch, label_batch)
        class_names  : list of all class names (length = num_classes)
        total_samples: total number of images in this split
    """
    # Augmentation only for training
    if augment:
        datagen = ImageDataGenerator(
            rescale          = 1.0 / 255,
            rotation_range   = 20,
            width_shift_range= 0.1,
            height_shift_range=0.1,
            shear_range      = 0.1,
            zoom_range       = 0.15,
            horizontal_flip  = True,
            fill_mode        = "nearest",
        )
    else:
        datagen = ImageDataGenerator(rescale=1.0 / 255)

    # Build global class list (consistent across all splits)
    all_class_names = get_all_class_names("Train")  # always use Train as reference
    num_classes     = len(all_class_names)
    class_to_idx    = {name: i for i, name in enumerate(all_class_names)}

    datasets      = []
    total_samples = 0

    for crop in CROP_FOLDERS:
        split_path = os.path.join(DATA_DIR, crop, split)
        if not os.path.isdir(split_path):
            continue

        gen = datagen.flow_from_directory(
            split_path,
            target_size = IMG_SIZE,
            batch_size  = BATCH_SIZE,
            class_mode  = "categorical",
            seed        = SEED,
            shuffle     = (split == "Train"),
        )
        total_samples += gen.samples

        # Map local class indices → global class indices
        local_to_global = {
            local_idx: class_to_idx[f"{crop}__{cls_name}"]
            for cls_name, local_idx in gen.class_indices.items()
            if f"{crop}__{cls_name}" in class_to_idx
        }

        print(f"  ✅ {crop:15s} [{split}] — {gen.samples:,} images, "
              f"{len(gen.class_indices)} classes")

        # Wrap generator to remap one-hot labels to global indices
        def make_remap_gen(g, mapping, n):
            def remap():
                while True:
                    X, y_local = next(g)
                    y_global = np.zeros((len(y_local), n), dtype="float32")
                    for i, li in enumerate(np.argmax(y_local, axis=1)):
                        if li in mapping:
                            y_global[i, mapping[li]] = 1.0
                    yield X, y_global
            return remap

        remap_fn = make_remap_gen(gen, local_to_global, num_classes)

        ds = tf.data.Dataset.from_generator(
            remap_fn,
            output_signature=(
                tf.TensorSpec(shape=(None, *IMG_SIZE, 3), dtype=tf.float32),
                tf.TensorSpec(shape=(None, num_classes),  dtype=tf.float32),
            ),
        )
        datasets.append(ds)

    if not datasets:
        raise RuntimeError(f"No data found in {DATA_DIR}. "
                           f"Check that Corn (Maize)/, Potato/, Tomato/ exist inside models/data/")

    # Merge all crop datasets
    combined = datasets[0]
    for ds in datasets[1:]:
        combined = combined.concatenate(ds)

    if split == "Train":
        combined = combined.shuffle(buffer_size=100, seed=SEED)

    return combined, all_class_names, total_samples


def save_labels(class_names: list, path: str = None) -> dict:
    """
    Saves index → class name mapping to labels.json
    Saved next to this file (models/labels.json) by default.
    """
    if path is None:
        path = os.path.join(_THIS_DIR, "labels.json")

    mapping = {str(i): name for i, name in enumerate(class_names)}
    with open(path, "w") as f:
        json.dump(mapping, f, indent=2)
    print(f"✅ labels.json saved → {path}")
    return mapping


# ── Run directly to verify your dataset ──────────────────────────────────────
if __name__ == "__main__":
    print("=" * 60)
    print("  AgroSentinel — Dataset Verification")
    print(f"  Data dir: {DATA_DIR}")
    print("=" * 60)

    all_ok = True
    grand_total = 0

    for split in ["Train", "Val", "Test"]:
        print(f"\n📂 {split} split:")
        try:
            ds, class_names, total = get_unified_dataset(split)
            grand_total += total
            print(f"   → {total:,} images, {len(class_names)} classes")
        except Exception as e:
            print(f"   ❌ Error: {e}")
            all_ok = False

    if all_ok:
        print(f"\n📊 Grand total : {grand_total:,} images")
        print(f"   Classes     : {len(class_names)}")
        print("\nAll classes found:")
        for i, name in enumerate(class_names):
            print(f"  [{i:02d}] {name}")
        save_labels(class_names)
        print("\n✅ Dataset looks good — run train.py next!")
    else:
        print("\n❌ Fix the errors above before training.")