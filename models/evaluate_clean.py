"""
evaluate_clean.py  -  AgroSentinel AI  
======================================================================

Run from the models/ folder:
    python evaluate_clean.py                         
    python evaluate_clean.py crop_model_federated.h5
    python evaluate_clean.py crop_model.h5 nearest     
"""

import os
import re
import sys
import json
import numpy as np

CROPS    = ["Corn (Maize)", "Potato", "Rice", "Tomato"]
IMG_EXT  = (".jpg", ".jpeg", ".png", ".bmp", ".tif", ".tiff")
IMG_SIZE = (224, 224)
NEAREST  = len(sys.argv) > 2 and sys.argv[2].lower() == "nearest"   # resize method switch


def base(fname):
    """File name without extension and without the augmentation suffix."""
    stem = os.path.splitext(fname)[0]
    return re.sub(r"_(flip(TB|LR)|\d+deg)$", "", stem, flags=re.I).lower()


def collect(data_dir):
    """All images with crop / class / split / path / base name."""
    recs = []
    for crop in CROPS:
        crop_dir = os.path.join(data_dir, crop)
        if not os.path.isdir(crop_dir):
            continue
        for split_dir in os.listdir(crop_dir):
            split = split_dir.lower()
            if split not in ("train", "val", "test"):
                continue
            sp = os.path.join(crop_dir, split_dir)
            for disease in sorted(os.listdir(sp)):
                dp = os.path.join(sp, disease)
                if not os.path.isdir(dp):
                    continue
                for root, _, files in os.walk(dp):
                    for f in files:
                        if f.lower().endswith(IMG_EXT):
                            recs.append({"crop": crop, "disease": disease, "split": split,
                                         "path": os.path.join(root, f), "base": base(f)})
    return recs


def key(r):
    return (r["crop"], r["disease"].lower(), r["base"])


def find_leaks(recs):
    """Flags for test files (sibling in train/val) and val files (sibling in train)."""
    train_keys    = {key(r) for r in recs if r["split"] == "train"}
    trainval_keys = train_keys | {key(r) for r in recs if r["split"] == "val"}
    for r in recs:
        if r["split"] == "test":
            r["leaked"] = key(r) in trainval_keys
        elif r["split"] == "val":
            r["leaked"] = key(r) in train_keys
    return recs


def predict(model, paths, bs=32):
    from PIL import Image
    out = []
    for i in range(0, len(paths), bs):
        batch = []
        for p in paths[i:i + bs]:
            img = Image.open(p).convert("RGB").resize(IMG_SIZE, Image.NEAREST if NEAREST else Image.LANCZOS)
            batch.append(np.asarray(img, dtype=np.float32))      # raw 0-255
        out.extend(np.argmax(model.predict(np.stack(batch), verbose=0), axis=1).tolist())
        print(f"   {min(i + bs, len(paths))}/{len(paths)}", end="\r")
    print()
    return np.array(out)


def main():
    import tensorflow as tf
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt
    from sklearn.metrics import confusion_matrix, ConfusionMatrixDisplay

    here       = os.path.dirname(os.path.abspath(__file__))
    model_file = sys.argv[1] if len(sys.argv) > 1 else "crop_model.h5"
    stem       = os.path.splitext(os.path.basename(model_file))[0]
    if NEAREST:
        stem += "_nearest"
    print(f"\nModel evaluated : {model_file}")

    with open(os.path.join(here, "labels.json")) as f:
        labels = json.load(f)
    name_to_idx = {v.lower(): int(k) for k, v in labels.items()}
    short = [labels[str(i)].split("__", 1)[-1] for i in range(len(labels))]

    recs = find_leaks(collect(os.path.join(here, "data")))
    for r in recs:
        r["idx"] = name_to_idx.get(f"{r['crop']}__{r['disease']}".lower())
        if r["idx"] is None:
            print(f"  ! cannot map {r['crop']}/{r['disease']} to labels.json")

    test = [r for r in recs if r["split"] == "test" and r["idx"] is not None]
    val  = [r for r in recs if r["split"] == "val"]
    lines = [f"Model: {model_file}  (resize: {'nearest' if NEAREST else 'lanczos'})", ""]

    lines.append("Files found (recursive scan):")
    for c in CROPS:
        n = {s: sum(1 for r in recs if r["crop"] == c and r["split"] == s) for s in ("train", "val", "test")}
        lines.append(f"  {c:13s} train {n['train']:6d} | val {n['val']:5d} | test {n['test']:4d}")
    lines.append(f"  TEST total: {len(test)}")
    lines.append("")

    n_leak = sum(r["leaked"] for r in test)
    v_leak = sum(r["leaked"] for r in val)
    lines.append(f"Test images with a sibling in Train/Val : {n_leak} of {len(test)} ({100 * n_leak / len(test):.1f}%)")
    for c in CROPS:
        t = [r for r in test if r["crop"] == c]
        if t:
            lines.append(f"    {c:13s}: {sum(r['leaked'] for r in t)} of {len(t)}")
    lines.append(f"Val images with a sibling in Train      : {v_leak} of {len(val)} ({100 * v_leak / max(len(val), 1):.1f}%)")
    lines.append("")

    model = tf.keras.models.load_model(os.path.join(here, model_file))
    print(f"Predicting {len(test)} test images...")
    y_pred = predict(model, [r["path"] for r in test])
    y_true = np.array([r["idx"] for r in test])
    crop_a = np.array([r["crop"] for r in test])
    leaked = np.array([r["leaked"] for r in test])

    def summarize(title, mask):
        out = [title]
        if mask.sum() == 0:
            return out + ["  (no images)", ""]
        out.append(f"  Overall      : {100 * np.mean(y_pred[mask] == y_true[mask]):6.2f}%  ({int(mask.sum())} images)")
        for c in CROPS:
            m = mask & (crop_a == c)
            if m.sum():
                out.append(f"  {c:13s}: {100 * np.mean(y_pred[m] == y_true[m]):6.2f}%  ({int(m.sum())} images)")
        return out + [""]

    lines += summarize("ALL test images", np.ones(len(test), dtype=bool))
    lines += summarize("CLEAN subset (no detected sibling in Train/Val)", ~leaked)
    lines += summarize("LEAKED subset (has a sibling in Train/Val)", leaked)

    clean = ~leaked
    if clean.sum():
        cm = confusion_matrix(y_true[clean], y_pred[clean], labels=list(range(len(labels))))
        fig, ax = plt.subplots(figsize=(14, 14))
        ConfusionMatrixDisplay(cm, display_labels=short).plot(ax=ax, xticks_rotation=45, colorbar=True, cmap="Blues")
        acc_c = 100 * np.mean(y_pred[clean] == y_true[clean])
        ax.set_title(f"AgroSentinel AI - Confusion matrix, CLEAN test subset ({int(clean.sum())} images)\n"
                     f"{model_file} - accuracy {acc_c:.2f}%")
        plt.tight_layout()
        png = os.path.join(here, f"confusion_matrix_clean_{stem}.png")
        plt.savefig(png, dpi=150, bbox_inches="tight")
        lines.append(f"Saved: {os.path.basename(png)}")

    txt = os.path.join(here, f"clean_report_{stem}.txt")
    with open(txt, "w", encoding="utf-8") as f:
        f.write("\n".join(lines))
    print("\n" + "\n".join(lines))
    print(f"Saved: {os.path.basename(txt)}")


if __name__ == "__main__":
    main()