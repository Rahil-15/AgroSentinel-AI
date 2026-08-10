"""
evaluate.py

Run from models/ folder:
    python evaluate.py
"""

import os
import json
import numpy as np
import tensorflow as tf
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from sklearn.metrics import classification_report, confusion_matrix, ConfusionMatrixDisplay
from PIL import Image

_HERE       = os.path.dirname(os.path.abspath(__file__))
MODEL_PATH  = os.path.join(_HERE, "crop_model.h5")
LABELS_PATH = os.path.join(_HERE, "labels.json")
DATA_DIR    = os.path.join(_HERE, "data")
IMG_SIZE    = (224, 224)
BATCH_SIZE  = 32

CROP_FOLDERS = ["Corn (Maize)", "Potato", "Rice", "Tomato"]


def load_image(path: str) -> np.ndarray:
    """Raw [0,255] float32 — EfficientNetB0 normalises internally."""
    img = Image.open(path).convert("RGB").resize(IMG_SIZE, Image.LANCZOS)
    return np.array(img, dtype=np.float32)


def evaluate():
    print("=" * 62)
    print("  AgroSentinel AI — Model Evaluation (Test split, v3)")
    print("=" * 62)

    # ── Load model + labels ───────────────────────────────────────────────
    print(f"\nLoading model...")
    model = tf.keras.models.load_model(MODEL_PATH)

    with open(LABELS_PATH) as f:
        labels = json.load(f)

    # labels.json: {"0": "Corn (Maize)__Cercospora Leaf Spot", ...}
    class_names = [labels[str(i)] for i in range(len(labels))]
    num_classes  = len(class_names)
    short_names  = [n.split("__", 1)[-1] for n in class_names]

    # Build lookup: "Corn (Maize)__Cercospora Leaf Spot" → 0
    name_to_global = {v: int(k) for k, v in labels.items()}

    print(f"   Classes : {num_classes}")

    # ── Collect test images ───────────────────────────────────────────────
    print("\nScanning Test folders...")
    all_paths  = []
    all_trues  = []

    for crop in CROP_FOLDERS:
        for split_name in ["Test", "test"]:
            test_path = os.path.join(DATA_DIR, crop, split_name)
            if os.path.isdir(test_path):
                break
        else:
            print(f"  {crop}: no Test folder found")
            continue

        crop_count = 0
        for disease in sorted(os.listdir(test_path)):
            disease_path = os.path.join(test_path, disease)
            if not os.path.isdir(disease_path):
                continue

            # Try exact match first, then case-insensitive
            label_key = f"{crop}__{disease}"
            global_idx = name_to_global.get(label_key)

            if global_idx is None:
                for name, idx in name_to_global.items():
                    if name.lower() == label_key.lower():
                        global_idx = idx
                        break

            if global_idx is None:
                print(f"  Cannot map: '{label_key}' — skipping")
                continue

            imgs = [
                os.path.join(disease_path, f)
                for f in os.listdir(disease_path)
                if f.lower().endswith(('.jpg', '.jpeg', '.png', '.bmp'))
            ]
            all_paths.extend(imgs)
            all_trues.extend([global_idx] * len(imgs))
            crop_count += len(imgs)

        print(f"  {crop:15s} — {crop_count} test images")

    total = len(all_paths)
    print(f"\n   Total test images : {total:,}")

    if total == 0:
        print("No test images found.")
        return

    # ── Run predictions in batches ────────────────────────────────────────
    print(f"\nRunning predictions...")
    all_preds = []

    for start in range(0, total, BATCH_SIZE):
        batch = all_paths[start:start + BATCH_SIZE]
        imgs  = np.stack([load_image(p) for p in batch])
        preds = model.predict(imgs, verbose=0)
        all_preds.extend(np.argmax(preds, axis=1).tolist())
        print(f"   {min(start+BATCH_SIZE, total)}/{total}", end="\r")

    all_preds = np.array(all_preds)
    all_trues = np.array(all_trues)

    print(f"\n   Predicted classes : {sorted(set(all_preds.tolist()))}")
    print(f"   True classes      : {sorted(set(all_trues.tolist()))}")

    # ── Overall accuracy ──────────────────────────────────────────────────
    accuracy = np.mean(all_preds == all_trues) * 100
    print(f"\nOverall Test Accuracy : {accuracy:.2f}%")

    # ── Per-class report ──────────────────────────────────────────────────
    present  = sorted(set(all_trues.tolist()) | set(all_preds.tolist()))
    p_names  = [short_names[i] for i in present]

    print("\nPer-class Classification Report:")
    print("-" * 62)
    report = classification_report(
        all_trues, all_preds,
        labels=present,
        target_names=p_names,
        digits=3,
        zero_division=0,
    )
    print(report)

    report_path = os.path.join(_HERE, "evaluation_report.txt")
    with open(report_path, "w") as f:
        f.write("AgroSentinel AI — Evaluation Report\n")
        f.write(f"Model         : EfficientNetB0\n")
        f.write(f"Crops         : Corn (Maize), Potato, Rice, Tomato\n")
        f.write(f"Total classes : {num_classes}\n")
        f.write(f"Test images   : {total}\n")
        f.write(f"Overall Accuracy: {accuracy:.2f}%\n\n")
        f.write(report)
    print(f"Saved → evaluation_report.txt")

    # ── Per-crop accuracy ─────────────────────────────────────────────────
    print("\nAccuracy by crop:")
    print("-" * 46)
    for crop in CROP_FOLDERS:
        idxs = [i for i, n in enumerate(class_names) if n.startswith(f"{crop}__")]
        mask = np.isin(all_trues, idxs)
        if mask.sum() == 0:
            print(f"   {crop:20s}: no test samples")
            continue
        acc   = np.mean(all_preds[mask] == all_trues[mask]) * 100
        count = int(mask.sum())
        print(f"   {crop.replace(' (Maize)',''):10s}: {acc:.2f}%  ({count} images)")

    # ── Confusion matrix ──────────────────────────────────────────────────
    print("\nSaving confusion matrix...")
    cm      = confusion_matrix(all_trues, all_preds, labels=present)
    fs      = max(14, len(present))
    fig, ax = plt.subplots(figsize=(fs, fs))
    ConfusionMatrixDisplay(cm, display_labels=p_names).plot(
        ax=ax, xticks_rotation=45, colorbar=True, cmap="Blues"
    )
    ax.set_title(
        f"AgroSentinel AI — Confusion Matrix\n"
        f"EfficientNetB0 · {num_classes} classes · Test Accuracy: {accuracy:.2f}%",
        fontsize=12, pad=16,
    )
    plt.tight_layout()
    plt.savefig(os.path.join(_HERE, "confusion_matrix.png"), dpi=150, bbox_inches="tight")
    plt.close()
    print(f"Saved → confusion_matrix.png")

    print("\n" + "=" * 62)
    print(f"  Final Test Accuracy : {accuracy:.2f}%")
    print(f"  Files: evaluation_report.txt · confusion_matrix.png")
    print("=" * 62)


if __name__ == "__main__":
    evaluate()