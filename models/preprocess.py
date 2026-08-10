"""
preprocess.py  —  AgroSentinel AI

Folder structure expected:
    models/data/
        Corn (Maize)/  Train/ Val/ Test/
        Potato/        Train/ Val/ Test/
        Rice/          Train/ Val/ Test/
        Tomato/        Train/ Val/ Test/
"""

import os
import json
import shutil
import tempfile
import tensorflow as tf
from tensorflow.keras.preprocessing.image import ImageDataGenerator

IMG_SIZE    = (224, 224)
BATCH_SIZE  = 32
SEED        = 42

CROP_FOLDERS = ["Corn (Maize)", "Potato", "Rice", "Tomato"]

_HERE    = os.path.dirname(os.path.abspath(__file__))
DATA_DIR = os.path.join(_HERE, "data")


def _build_flat_split(split: str) -> str:
    
    tmp_dir = tempfile.mkdtemp(prefix=f"agrosentinel_{split}_")

    for crop in CROP_FOLDERS:
        split_path = os.path.join(DATA_DIR, crop, split)
        if not os.path.isdir(split_path):
            # try lowercase
            split_path = os.path.join(DATA_DIR, crop, split.lower())
            if not os.path.isdir(split_path):
                continue

        for disease in sorted(os.listdir(split_path)):
            disease_path = os.path.join(split_path, disease)
            if not os.path.isdir(disease_path):
                continue

            # Flat class name: "Corn (Maize)__Cercospora Leaf Spot"
            flat_name    = f"{crop}__{disease}"
            flat_cls_dir = os.path.join(tmp_dir, flat_name)
            os.makedirs(flat_cls_dir, exist_ok=True)

            # Symlink images instead of copying (fast, no disk waste)
            for img in os.listdir(disease_path):
                if img.lower().endswith(('.jpg', '.jpeg', '.png', '.bmp')):
                    src = os.path.join(disease_path, img)
                    dst = os.path.join(flat_cls_dir, img)
                    try:
                        os.symlink(src, dst)
                    except (OSError, NotImplementedError):
                        # Windows may not support symlinks — fall back to copy
                        shutil.copy2(src, dst)

    return tmp_dir


def get_unified_dataset(split: str, augment: bool = False):
   
    print(f"  Building flat {split} directory...")
    tmp_dir = _build_flat_split(split)

    if augment:
        datagen = ImageDataGenerator(
            rotation_range=20,
            width_shift_range=0.1,
            height_shift_range=0.1,
            shear_range=0.1,
            zoom_range=0.15,
            horizontal_flip=True,
            fill_mode="nearest",
        )
    else:
        datagen = ImageDataGenerator()   # no rescale — EfficientNet handles it

    gen = datagen.flow_from_directory(
        tmp_dir,
        target_size=IMG_SIZE,
        batch_size=BATCH_SIZE,
        class_mode="categorical",
        seed=SEED,
        shuffle=(split == "Train"),
    )

    class_names = [None] * len(gen.class_indices)
    for name, idx in gen.class_indices.items():
        class_names[idx] = name

    total_samples = gen.samples

    # Print per-crop summary
    for crop in CROP_FOLDERS:
        crop_classes = [n for n in class_names if n and n.startswith(f"{crop}__")]
        crop_images  = sum(
            len([f for f in os.listdir(os.path.join(tmp_dir, c))
                 if not f.startswith('.')])
            for c in crop_classes
            if os.path.isdir(os.path.join(tmp_dir, c))
        )
        if crop_classes:
            print(f"  {crop:15s} [{split}] — {crop_images:,} images, "
                  f"{len(crop_classes)} classes")

    print(f"   → {total_samples:,} images, {len(class_names)} classes")

    # Convert generator to tf.data.Dataset
    ds = tf.data.Dataset.from_generator(
        lambda: gen,
        output_signature=(
            tf.TensorSpec(shape=(None, *IMG_SIZE, 3), dtype=tf.float32),
            tf.TensorSpec(shape=(None, len(class_names)), dtype=tf.float32),
        ),
    )

    if split == "Train":
        ds = ds.shuffle(buffer_size=64, seed=SEED)

    # Schedule temp dir cleanup
    import atexit
    atexit.register(shutil.rmtree, tmp_dir, True)

    return ds, class_names, total_samples


def save_labels(class_names: list, path: str = None) -> dict:
    if path is None:
        path = os.path.join(_HERE, "labels.json")
    mapping = {str(i): name for i, name in enumerate(class_names)}
    with open(path, "w") as f:
        json.dump(mapping, f, indent=2)
    print(f"labels.json saved → {path}")
    return mapping


if __name__ == "__main__":
    print("=" * 60)
    print("  AgroSentinel — Dataset Verification (v3)")
    print(f"  Data dir: {DATA_DIR}")
    print("=" * 60)

    grand_total = 0
    class_names = None

    for split in ["Train", "Val", "Test"]:
        print(f"\n{split} split:")
        ds, class_names, total = get_unified_dataset(split)
        grand_total += total

    print(f"\n Grand total : {grand_total:,} images")
    print(f"   Classes     : {len(class_names)}")
    print("\nAll classes (global index order):")
    for i, name in enumerate(class_names):
        print(f"  [{i:02d}] {name}")

    save_labels(class_names)
    print("\nDataset looks good — run train.py next!")