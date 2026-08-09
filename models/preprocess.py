"""
preprocess.py  —  AgroSentinel AI  (v2 fixed)
==============================================
Crops: Corn (Maize) | Potato | Rice | Tomato  →  16 classes
"""
import os
import json
import tensorflow as tf
from tensorflow.keras.preprocessing.image import ImageDataGenerator

# ── CONFIG ────────────────────────────────────────────────────────────────────
IMG_SIZE     = (224, 224)
BATCH_SIZE   = 32
SEED         = 42

CROP_FOLDERS = [
    "Corn (Maize)",
    "Potato",
    "Rice",
    "Tomato",
]

_HERE    = os.path.dirname(os.path.abspath(__file__))
DATA_DIR = os.path.join(_HERE, "data")


def _make_datagen(augment: bool) -> ImageDataGenerator:
    """
    IMPORTANT: No rescale here.
    EfficientNetB0 includes tf.keras.applications.efficientnet.preprocess_input
    internally which handles pixel normalisation itself.
    Passing rescale=1/255 would double-normalise and break the model.
    """
    if augment:
        return ImageDataGenerator(
            # NO rescale — EfficientNet handles this internally
            rotation_range=20,
            width_shift_range=0.1,
            height_shift_range=0.1,
            shear_range=0.1,
            zoom_range=0.15,
            horizontal_flip=True,
            fill_mode="nearest",
        )
    return ImageDataGenerator()   # NO rescale


def _collect_class_names(split: str = "Train") -> list:
    names = []
    for crop in CROP_FOLDERS:
        split_path = os.path.join(DATA_DIR, crop, split)
        if not os.path.isdir(split_path):
            continue
        for cls in sorted(os.listdir(split_path)):
            if os.path.isdir(os.path.join(split_path, cls)):
                names.append(f"{crop}__{cls}")
    return names


def get_unified_dataset(split: str, augment: bool = False):
    """
    Returns (tf.data.Dataset, class_names_list, total_sample_count)
    Merges all 4 crop generators into one dataset with unified global labels.
    """
    datagen      = _make_datagen(augment)
    all_names    = _collect_class_names("Train")
    num_classes  = len(all_names)
    class_to_idx = {n: i for i, n in enumerate(all_names)}

    datasets      = []
    total_samples = 0

    for crop in CROP_FOLDERS:
        split_path = os.path.join(DATA_DIR, crop, split)
        if not os.path.isdir(split_path):
            print(f"  ⚠️  Missing: {split_path} — skipping")
            continue

        gen = datagen.flow_from_directory(
            split_path,
            target_size=IMG_SIZE,
            batch_size=BATCH_SIZE,
            class_mode="categorical",
            seed=SEED,
            shuffle=(split == "Train"),
        )
        total_samples += gen.samples
        print(f"  ✅ {crop:15s} [{split}] — {gen.samples:,} images, "
              f"{len(gen.class_indices)} classes")

        local_to_global = {
            local_idx: class_to_idx[f"{crop}__{cls_name}"]
            for cls_name, local_idx in gen.class_indices.items()
        }

        def _make_generator(g, mapping, n):
            import numpy as np
            def _gen():
                while True:
                    X, y_local = next(g)
                    y_global = np.zeros((len(y_local), n), dtype="float32")
                    for i, li in enumerate(y_local.argmax(axis=1)):
                        y_global[i, mapping[li]] = 1.0
                    yield X, y_global
            return _gen

        ds = tf.data.Dataset.from_generator(
            _make_generator(gen, local_to_global, num_classes),
            output_signature=(
                tf.TensorSpec(shape=(None, *IMG_SIZE, 3), dtype=tf.float32),
                tf.TensorSpec(shape=(None, num_classes),  dtype=tf.float32),
            ),
        )
        datasets.append(ds)

    if not datasets:
        raise RuntimeError(f"No data found for split='{split}' in {DATA_DIR}")

    combined = datasets[0]
    for ds in datasets[1:]:
        combined = combined.concatenate(ds)

    if split == "Train":
        combined = combined.shuffle(buffer_size=64, seed=SEED)

    return combined, all_names, total_samples


def save_labels(class_names: list, path: str = None) -> dict:
    if path is None:
        path = os.path.join(_HERE, "labels.json")
    mapping = {str(i): name for i, name in enumerate(class_names)}
    with open(path, "w") as f:
        json.dump(mapping, f, indent=2)
    print(f"✅ labels.json saved → {path}")
    return mapping


if __name__ == "__main__":
    print("=" * 58)
    print("  AgroSentinel — Dataset Verification (v2 — 4 crops)")
    print(f"  Data dir: {DATA_DIR}")
    print("=" * 58)

    grand_total = 0
    class_names = None

    for split in ["Train", "Val", "Test"]:
        print(f"\n📂 {split} split:")
        ds, class_names, total = get_unified_dataset(split)
        print(f"   → {total:,} images, {len(class_names)} classes")
        grand_total += total

    print(f"\n📊 Grand total : {grand_total:,} images")
    print(f"   Classes     : {len(class_names)}")
    print("\nAll classes found:")
    for i, name in enumerate(class_names):
        print(f"  [{i:02d}] {name}")

    save_labels(class_names)
    print("\n✅ Dataset looks good — run train.py next!")