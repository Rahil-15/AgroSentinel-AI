

import os
import sys
import io
import json
import base64
import numpy as np
from PIL import Image
import tensorflow as tf
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

_HERE       = os.path.dirname(os.path.abspath(__file__))
MODEL_PATH  = os.path.join(_HERE, "crop_model.h5")
LABELS_PATH = os.path.join(_HERE, "labels.json")
IMG_SIZE    = (224, 224)

_model  = None
_labels = None


def _load():
    global _model, _labels
    if _model is not None:
        return _model, _labels
    print(" Grad-CAM: loading model...")
    _model = tf.keras.models.load_model(MODEL_PATH)
    with open(LABELS_PATH) as f:
        _labels = json.load(f)
    print(f" Grad-CAM ready — {len(_labels)} classes")
    return _model, _labels


def _preprocess(img: Image.Image) -> np.ndarray:
    img = img.convert("RGB").resize(IMG_SIZE, Image.LANCZOS)
    return np.expand_dims(np.array(img, dtype=np.float32), axis=0)


def _open_image(image_input) -> Image.Image:
    if isinstance(image_input, bytes):
        return Image.open(io.BytesIO(image_input)).convert("RGB")
    return Image.open(image_input).convert("RGB")


def _apply_colormap(heatmap_2d: np.ndarray) -> np.ndarray:
    
    cmap       = plt.get_cmap("jet")
    heatmap_rgb = cmap(heatmap_2d)          
    heatmap_rgb = (heatmap_rgb[:, :, :3] * 255).astype(np.uint8)  
    return heatmap_rgb


def _compute_gradcam(img_array: np.ndarray, class_idx: int) -> np.ndarray:
    
    model, _ = _load()
    img_var  = tf.Variable(img_array, dtype=tf.float32)

    with tf.GradientTape() as tape:
        tape.watch(img_var)
        preds      = model(img_var, training=False)
        class_score = preds[:, class_idx]

    grads = tape.gradient(class_score, img_var)   

    if grads is None:
        print("     Gradients are None — returning uniform heatmap")
        return np.ones(IMG_SIZE, dtype=np.float32) * 0.5

    saliency = tf.reduce_mean(tf.abs(grads[0]), axis=-1).numpy()

    saliency -= saliency.min()
    if saliency.max() > 0:
        saliency /= saliency.max()

    return saliency  


def _overlay_heatmap(
    original_img: Image.Image,
    heatmap: np.ndarray,
    alpha: float = 0.5,
) -> Image.Image:
    """Blend jet-coloured heatmap onto original leaf image."""
    img_w, img_h = original_img.size

    heatmap_pil  = Image.fromarray(np.uint8(heatmap * 255))
    heatmap_pil  = heatmap_pil.resize((img_w, img_h), Image.LANCZOS)
    heatmap_norm = np.array(heatmap_pil) / 255.0   

  
    heatmap_rgb  = _apply_colormap(heatmap_norm)   
    heatmap_img  = Image.fromarray(heatmap_rgb).convert("RGB")

   
    return Image.blend(original_img.convert("RGB"), heatmap_img, alpha=alpha)


def generate_gradcam(image_input, save_path: str = None) -> str:
    """
    Called by Poorvita's main.py.

    Args:
        image_input : bytes (FastAPI upload) OR str (file path for CLI testing)
        save_path   : optional — saves PNG to disk if given

    Returns:
        Base64-encoded PNG string for /predict JSON response.
    """
    model, labels = _load()
    original_img  = _open_image(image_input)
    img_array     = _preprocess(original_img)

    preds      = model(tf.constant(img_array, dtype=tf.float32), training=False)
    class_idx  = int(tf.argmax(preds[0]))

    heatmap = _compute_gradcam(img_array, class_idx)
    overlay = _overlay_heatmap(original_img, heatmap)

    if save_path:
        overlay.save(save_path)
        print(f" Saved → {save_path}")

    buf = io.BytesIO()
    overlay.save(buf, format="PNG")
    return base64.b64encode(buf.getvalue()).decode("utf-8")


def generate_gradcam_with_info(image_input) -> dict:
    """CLI test version — returns heatmap + full prediction info."""
    model, labels = _load()
    original_img  = _open_image(image_input)
    img_array     = _preprocess(original_img)

    preds      = model(tf.constant(img_array, dtype=tf.float32), training=False).numpy()[0]
    class_idx  = int(np.argmax(preds))
    confidence = float(preds[class_idx])
    class_name = labels.get(str(class_idx), f"class_{class_idx}")

    if "__" in class_name:
        crop, disease = class_name.split("__", 1)
        crop = crop.replace(" (Maize)", "").strip()
    else:
        crop, disease = "Unknown", class_name
    disease = disease.replace("_", " ").title()

    heatmap = _compute_gradcam(img_array, class_idx)
    overlay = _overlay_heatmap(original_img, heatmap)

    buf = io.BytesIO()
    overlay.save(buf, format="PNG")
    b64_str = base64.b64encode(buf.getvalue()).decode("utf-8")

    return {
        "crop":          crop,
        "disease":       disease,
        "confidence":    round(confidence, 4),
        "class_idx":     class_idx,
        "gradcam_image": b64_str,
        "explanation": (
            f"Red/yellow areas show where the model detected {disease} "
            f"patterns. Blue/green regions had low influence on the prediction."
        ),
    }


# ── CLI ───────────────────────────────────────────────────────────────────────
if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage  : python gradcam.py <full_path_to_image>")
        print("Example: python gradcam.py \"R:\\...\\BROWNSPOT1_083.jpg\"")
        sys.exit(1)

    image_path = sys.argv[1]
    print(f"\n Generating Grad-CAM: {image_path}")

    result   = generate_gradcam_with_info(image_path)
    out_path = os.path.join(_HERE, "gradcam_output.png")

    with open(out_path, "wb") as f:
        f.write(base64.b64decode(result["gradcam_image"]))

    print("\n" + "=" * 56)
    print(f"  Crop       : {result['crop']}")
    print(f"  Disease    : {result['disease']}")
    print(f"  Confidence : {result['confidence'] * 100:.1f}%")
    print(f"             : {result['explanation']}")
    print(f"  Base64 len : {len(result['gradcam_image'])} chars")
    print("=" * 56)
    print(f"\nOpen this file to see the heatmap:")
    print(f"   {out_path}")