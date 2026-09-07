"""
predict_single.py  —  AgroSentinel AI  

Import in FastAPI:
    from predict_single import load_model_once, predict_image
"""

import os
import sys
import json
import io
import numpy as np
from PIL import Image
import tensorflow as tf

_HERE       = os.path.dirname(os.path.abspath(__file__))
MODEL_PATH  = os.path.join(_HERE, "crop_model.h5")
LABELS_PATH = os.path.join(_HERE, "labels.json")
IMG_SIZE    = (224, 224)
TOP_K       = 3

# ── Confidence threshold for OOD rejection ────────────────────────────────────
# If the model's top prediction confidence is below this value,
# the input is likely an unsupported crop and we reject it.
# Rationale: supported crop leaves score 90-100% confidence.
#            unknown leaves spread probability and score 40-65%.
CONFIDENCE_THRESHOLD = 0.65

# Supported crops — shown to farmer in rejection message
SUPPORTED_CROPS = ["Corn (Maize)", "Potato", "Rice", "Tomato"]

_model  = None
_labels = None


def load_model_once():
    global _model, _labels
    if _model is None:
        if not os.path.exists(MODEL_PATH):
            raise FileNotFoundError(
                f"crop_model.h5 not found at {MODEL_PATH}\n"
                "Run python train.py first."
            )
        print(" Loading EfficientNetB0 model...")
        _model = tf.keras.models.load_model(MODEL_PATH)
        with open(LABELS_PATH) as f:
            _labels = json.load(f)
        print(f" Model ready — {len(_labels)} classes")
    return _model, _labels


def _preprocess(img: Image.Image) -> np.ndarray:
    """Resize to 224×224. NO /255 — EfficientNet normalises internally."""
    img = img.convert("RGB").resize(IMG_SIZE, Image.LANCZOS)
    arr = np.array(img, dtype=np.float32)
    return np.expand_dims(arr, axis=0)


def predict_image(image_input) -> dict:
   
    model, labels = load_model_once()

    # Load image
    if isinstance(image_input, bytes):
        img = Image.open(io.BytesIO(image_input))
    else:
        img = Image.open(image_input)

    arr   = _preprocess(img)
    preds = model.predict(arr, verbose=0)[0]   # shape: (num_classes,)

    top_idx  = int(np.argmax(preds))
    top_conf = float(preds[top_idx])
    top_label = labels[str(top_idx)]

    if top_conf < CONFIDENCE_THRESHOLD:
        top_k_idx = np.argsort(preds)[::-1][:TOP_K]
        top3 = [
            {
                "label":      labels[str(i)].replace("__", " — ").title(),
                "confidence": round(float(preds[i]), 4),
            }
            for i in top_k_idx
        ]
        return {
            "crop":         "Unknown",
            "disease":      "Unrecognised plant or leaf",
            "confidence":   round(top_conf, 4),
            "is_healthy":   False,
            "is_supported": False,
            "message": (
                f"This leaf does not match any of our supported crops. "
                f"AgroSentinel AI currently supports: "
                f"{', '.join(SUPPORTED_CROPS)}. "
                f"Please ensure you are scanning a supported crop leaf "
                f"in clear lighting."
            ),
            "top3": top3,
        }

    if "__" in top_label:
        crop_raw, disease = top_label.split("__", 1)
        crop = crop_raw.replace(" (Maize)", "").strip()
    else:
        parts   = top_label.split("_")
        crop    = parts[0]
        disease = " ".join(parts[1:])

    disease    = disease.replace("_", " ").title()
    is_healthy = "healthy" in disease.lower()

    top_k_idx = np.argsort(preds)[::-1][:TOP_K]
    top3 = [
        {
            "label":      labels[str(i)].replace("__", " — ").replace("_", " ").title(),
            "confidence": round(float(preds[i]), 4),
        }
        for i in top_k_idx
    ]

    return {
        "crop":         crop,
        "disease":      disease,
        "confidence":   round(top_conf, 4),
        "is_healthy":   is_healthy,
        "is_supported": True,
        "message":      None,
        "top3":         top3,
    }


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage  : python predict_single.py <path_to_image>")
        print("Example: python predict_single.py data\\Rice\\test\\Brownspot\\img.jpg")
        sys.exit(1)

    result = predict_image(sys.argv[1])

    print("\n" + "=" * 55)
    if not result["is_supported"]:
        print(f"    UNSUPPORTED PLANT DETECTED")
        print(f"  Confidence was only {result['confidence']*100:.1f}% — below threshold")
        print(f"  Message: {result['message']}")
    else:
        print(f"   Crop       : {result['crop']}")
        print(f"   Disease    : {result['disease']}")
        print(f"   Confidence : {result['confidence'] * 100:.1f}%")
        print(f"   Healthy    : {result['is_healthy']}")
        print(f"   Supported  : {result['is_supported']}")
        print("\n  Top 3 predictions:")
        for i, p in enumerate(result["top3"], 1):
            bar = "█" * int(p["confidence"] * 20)
            print(f"    {i}. {p['label']:42s} {p['confidence']*100:5.1f}%  {bar}")
    print("=" * 55) 