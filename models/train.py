"""
train.py  —  AgroSentinel AI

Run from models/ folder:
    python train.py
"""

import os
import tensorflow as tf
from tensorflow.keras import layers, models, optimizers, callbacks
from tensorflow.keras.applications import EfficientNetB0

from preprocess import get_unified_dataset, save_labels, IMG_SIZE, BATCH_SIZE

EPOCHS_PHASE1    = 10
EPOCHS_PHASE2    = 10
LR_PHASE1        = 1e-3
LR_PHASE2        = 1e-5

_HERE            = os.path.dirname(os.path.abspath(__file__))
MODEL_SAVE_PATH  = os.path.join(_HERE, "crop_model.h5")
LABELS_SAVE_PATH = os.path.join(_HERE, "labels.json")


def build_model(num_classes: int):
    base = EfficientNetB0(
        input_shape=(*IMG_SIZE, 3),
        include_top=False,
        weights="imagenet",
    )
    base.trainable = False

    inputs  = tf.keras.Input(shape=(*IMG_SIZE, 3), name="image_input")
    x       = base(inputs, training=False)
    x       = layers.GlobalAveragePooling2D()(x)
    x       = layers.BatchNormalization()(x)
    x       = layers.Dense(256, activation="relu")(x)
    x       = layers.Dropout(0.4)(x)
    x       = layers.Dense(128, activation="relu")(x)
    x       = layers.Dropout(0.3)(x)
    outputs = layers.Dense(num_classes, activation="softmax", name="predictions")(x)

    return models.Model(inputs, outputs, name="AgroSentinel_EfficientNetB0"), base


def get_callbacks(phase: int) -> list:
    return [
        callbacks.ModelCheckpoint(
            MODEL_SAVE_PATH,
            monitor="val_accuracy",
            save_best_only=True,
            verbose=1,
        ),
        callbacks.EarlyStopping(
            monitor="val_accuracy",
            patience=4,
            restore_best_weights=True,
            verbose=1,
        ),
        callbacks.ReduceLROnPlateau(
            monitor="val_loss",
            factor=0.5,
            patience=2,
            min_lr=1e-7,
            verbose=1,
        ),
    ]


def train():
    print("=" * 62)
    print("  AgroSentinel AI — Training (v3, EfficientNetB0, 4 crops)")
    print("=" * 62)

    print("\nLoading Train split...")
    train_ds, class_names, train_total = get_unified_dataset("Train", augment=True)

    print("\nLoading Val split...")
    val_ds, _, val_total = get_unified_dataset("Val", augment=False)

    num_classes     = len(class_names)
    save_labels(class_names, LABELS_SAVE_PATH)
    steps_per_epoch = max(1, train_total // BATCH_SIZE)
    val_steps       = max(1, val_total   // BATCH_SIZE)

    print(f"\nDataset summary:")
    print(f"   Total classes : {num_classes}")
    print(f"   Train samples : {train_total:,}")
    print(f"   Val   samples : {val_total:,}")
    print(f"   Image size    : {IMG_SIZE[0]}×{IMG_SIZE[1]}")
    print(f"   Batch size    : {BATCH_SIZE}")

    print(f"\n🏗️Building EfficientNetB0 model ({num_classes} output classes)...")
    model, base = build_model(num_classes)
    model.summary()

    # Phase 1
    print("\n" + "=" * 62)
    print("  Phase 1 — Training head (base frozen)")
    print("=" * 62)
    model.compile(
        optimizer=optimizers.Adam(LR_PHASE1),
        loss="categorical_crossentropy",
        metrics=["accuracy"],
    )
    h1 = model.fit(
        train_ds,
        epochs=EPOCHS_PHASE1,
        steps_per_epoch=steps_per_epoch,
        validation_data=val_ds,
        validation_steps=val_steps,
        callbacks=get_callbacks(1),
        verbose=1,
    )
    phase1_best = max(h1.history["val_accuracy"])
    print(f"\n  Phase 1 best val accuracy: {phase1_best * 100:.2f}%")

    # Phase 2
    print("\n" + "=" * 62)
    print("  Phase 2 — Fine-tuning top 20 EfficientNetB0 layers")
    print("=" * 62)
    base.trainable = True
    for layer in base.layers[:-20]:
        layer.trainable = False
    model.compile(
        optimizer=optimizers.Adam(LR_PHASE2),
        loss="categorical_crossentropy",
        metrics=["accuracy"],
    )
    h2 = model.fit(
        train_ds,
        epochs=EPOCHS_PHASE2,
        steps_per_epoch=steps_per_epoch,
        validation_data=val_ds,
        validation_steps=val_steps,
        callbacks=get_callbacks(2),
        verbose=1,
    )
    phase2_best  = max(h2.history["val_accuracy"])
    overall_best = max(phase1_best, phase2_best)

    print("\n" + "=" * 62)
    print(f"  Training complete!")
    print(f"  Phase 1 best : {phase1_best  * 100:.2f}%")
    print(f"  Phase 2 best : {phase2_best  * 100:.2f}%")
    print(f"  Overall best : {overall_best * 100:.2f}%")
    print(f"  Model saved  : {MODEL_SAVE_PATH}")
    print("=" * 62)
    print("\n  Next step: run python evaluate.py")
    return model


if __name__ == "__main__":
    gpus = tf.config.list_physical_devices("GPU")
    if gpus:
        tf.config.experimental.set_memory_growth(gpus[0], True)
        print(f"🖥️  GPU: {gpus[0].name}")
    else:
        print("💻 No GPU — training on CPU (3-5 hours, keep plugged in)\n")
    train()