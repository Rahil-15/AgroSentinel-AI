"""
train.py
========
Trains a MobileNetV2 crop disease classifier using your
pre-split Train/ Val/ Test/ folder structure.

Run from the AgroSentinel AI root folder:
    python models/train.py

Or from inside models/:
    python train.py
"""

import os
import json
import numpy as np
import tensorflow as tf
from tensorflow.keras import layers, models, optimizers, callbacks
from tensorflow.keras.applications import MobileNetV2

from preprocess import get_unified_dataset, save_labels, IMG_SIZE, BATCH_SIZE, DATA_DIR

# ── CONFIG ────────────────────────────────────────────────────────────────────
EPOCHS_PHASE1   = 10       # train top layers, base frozen
EPOCHS_PHASE2   = 10       # fine-tune top 40 base layers
LR_PHASE1       = 1e-3
LR_PHASE2       = 1e-5     # much smaller for fine-tuning
MODEL_SAVE_PATH = "crop_model.h5"


def build_model(num_classes: int):
    """
    MobileNetV2 pretrained on ImageNet + custom head.
    Lightweight enough to train on a laptop CPU.
    """
    base = MobileNetV2(
        input_shape=(*IMG_SIZE, 3),
        include_top=False,
        weights="imagenet",
    )
    base.trainable = False      # frozen in Phase 1

    inputs = tf.keras.Input(shape=(*IMG_SIZE, 3))
    x = base(inputs, training=False)
    x = layers.GlobalAveragePooling2D()(x)
    x = layers.BatchNormalization()(x)
    x = layers.Dense(256, activation="relu")(x)
    x = layers.Dropout(0.4)(x)
    x = layers.Dense(128, activation="relu")(x)
    x = layers.Dropout(0.3)(x)
    outputs = layers.Dense(num_classes, activation="softmax")(x)

    return models.Model(inputs, outputs), base


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
            verbose=1,
        ),
    ]


def train():
    print("=" * 60)
    print("  AgroSentinel AI — Crop Disease Model Training")
    print(f"  Data dir : {os.path.abspath(DATA_DIR)}")
    print("=" * 60)

    # ── Load datasets ─────────────────────────────────────────────────────
    print("\n📂 Loading Train split...")
    train_ds, class_names, train_total = get_unified_dataset("Train", augment=True)

    print("\n📂 Loading Val split...")
    val_ds, _, val_total = get_unified_dataset("Val", augment=False)

    num_classes = len(class_names)
    save_labels(class_names)

    print(f"\n📊 Summary:")
    print(f"   Classes          : {num_classes}")
    print(f"   Train samples    : {train_total:,}")
    print(f"   Val   samples    : {val_total:,}")

    # Steps per epoch
    steps_per_epoch  = max(1, train_total // BATCH_SIZE)
    val_steps        = max(1, val_total   // BATCH_SIZE)

    # ── Build model ───────────────────────────────────────────────────────
    model, base = build_model(num_classes)
    model.summary()

    # ── Phase 1: Train head only ──────────────────────────────────────────
    print("\n🚀 Phase 1 — Training classification head (base frozen)")
    print("-" * 60)

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

    # ── Phase 2: Fine-tune top 40 base layers ────────────────────────────
    print("\n🔧 Phase 2 — Fine-tuning top 40 layers of MobileNetV2")
    print("-" * 60)

    base.trainable = True
    for layer in base.layers[:-40]:
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

    # ── Done ──────────────────────────────────────────────────────────────
    best = max(
        max(h1.history["val_accuracy"]),
        max(h2.history["val_accuracy"]),
    )

    print("\n" + "=" * 60)
    print(f"  ✅ Training complete!")
    print(f"  Best val accuracy : {best * 100:.2f}%")
    print(f"  Model saved to    : {MODEL_SAVE_PATH}")
    print(f"  Classes           : {num_classes}")
    print("=" * 60)

    return model


if __name__ == "__main__":
    # GPU setup
    gpus = tf.config.list_physical_devices("GPU")
    if gpus:
        print(f"🖥️  GPU detected — {gpus[0].name}")
        tf.config.experimental.set_memory_growth(gpus[0], True)
    else:
        print("💻 No GPU — training on CPU (slower but works fine)")

    train()