"""
severity.py  —  AgroSentinel AI  Severity Agent (Agent 3)
=========================================================
Estimates disease severity from a leaf image using OpenCV HSV
colour segmentation.

How it works:
  1. Convert leaf image from RGB to HSV colour space
  2. Create a mask for GREEN pixels (healthy leaf tissue)
  3. Create a mask for BROWN/YELLOW/DARK pixels (diseased tissue)
  4. Calculate infected_pct = diseased pixels / total leaf pixels * 100
  5. Classify into Early / Moderate / Severe based on percentage

Why HSV and not RGB?
  HSV separates colour (Hue) from brightness (Value), making it much
  more reliable for detecting diseased tissue regardless of lighting
  conditions, shadow, or camera differences.

Output fed into Loss Agent (Agent 4):
  severity_label → used to look up yield_loss_pct from msp_data.json
  infected_pct   → shown in Flutter app as "18.4% of leaf infected"


Imported by Poorvita's main.py:
    from severity import estimate_severity
    result = estimate_severity(image_bytes)
"""

import os
import sys
import io
import json
import base64
import numpy as np
from PIL import Image
import cv2

_HERE = os.path.dirname(os.path.abspath(__file__))

# ── Severity thresholds ───────────────────────────────────────────────────────
# Based on standard agricultural disease assessment scales
THRESHOLDS = {
    "Early":    (0,  15),    # 0–15% infected
    "Moderate": (15, 40),    # 15–40% infected
    "Severe":   (40, 100),   # 40–100% infected
}

# ── HSV colour ranges ─────────────────────────────────────────────────────────
# OpenCV HSV: H=0-179, S=0-255, V=0-255

# Healthy green leaf tissue
GREEN_LOWER = np.array([25,  40,  40],  dtype=np.uint8)
GREEN_UPPER = np.array([90, 255, 255],  dtype=np.uint8)

# Diseased tissue — brown, yellow, dark spots
# Brown/tan (rust, blight)
BROWN_LOWER = np.array([5,  30,  20],  dtype=np.uint8)
BROWN_UPPER = np.array([25, 255, 200], dtype=np.uint8)

# Dark necrotic spots (severe blight, bacterial)
DARK_LOWER  = np.array([0,   0,   0],  dtype=np.uint8)
DARK_UPPER  = np.array([180, 80,  80], dtype=np.uint8)

# Yellow (early infection, viral)
YELLOW_LOWER = np.array([20,  60,  60],  dtype=np.uint8)
YELLOW_UPPER = np.array([35, 255, 255],  dtype=np.uint8)


def _open_image(image_input) -> np.ndarray:
    """
    Accept bytes (FastAPI) or file path (CLI testing).
    Returns OpenCV BGR numpy array.
    """
    if isinstance(image_input, bytes):
        img_pil = Image.open(io.BytesIO(image_input)).convert("RGB")
    else:
        img_pil = Image.open(image_input).convert("RGB")

    # Resize to standard size for consistent analysis
    img_pil = img_pil.resize((224, 224), Image.LANCZOS)

    # Convert PIL (RGB) → OpenCV (BGR)
    img_bgr = cv2.cvtColor(np.array(img_pil), cv2.COLOR_RGB2BGR)
    return img_bgr


def _classify_severity(infected_pct: float) -> str:
    """Map infected percentage to severity label."""
    if infected_pct < THRESHOLDS["Early"][1]:
        return "Early"
    elif infected_pct < THRESHOLDS["Moderate"][1]:
        return "Moderate"
    else:
        return "Severe"


def estimate_severity(image_input) -> dict:
    """
    Main function — called by Poorvita's main.py.

    Args:
        image_input : bytes (FastAPI upload) OR str (file path for CLI testing)

    Returns:
        {
            "severity":          "Moderate",
            "infected_pct":      18.4,
            "healthy_pct":       64.2,
            "background_pct":    17.4,
            "total_pixels":      50176,
            "diseased_pixels":   9232,
            "severity_message":  "Moderate infection — 18.4% of leaf affected"
        }
    """
    img_bgr = _open_image(image_input)
    img_hsv = cv2.cvtColor(img_bgr, cv2.COLOR_BGR2HSV)

    total_pixels = img_hsv.shape[0] * img_hsv.shape[1]

    # ── Green mask (healthy tissue) ───────────────────────────────────────
    green_mask  = cv2.inRange(img_hsv, GREEN_LOWER, GREEN_UPPER)

    # ── Disease masks ─────────────────────────────────────────────────────
    brown_mask  = cv2.inRange(img_hsv, BROWN_LOWER, BROWN_UPPER)
    dark_mask   = cv2.inRange(img_hsv, DARK_LOWER,  DARK_UPPER)
    yellow_mask = cv2.inRange(img_hsv, YELLOW_LOWER, YELLOW_UPPER)

    # Combine all disease indicators
    disease_mask_raw = cv2.bitwise_or(brown_mask, dark_mask)
    disease_mask_raw = cv2.bitwise_or(disease_mask_raw, yellow_mask)

    # Remove overlap with green (green takes priority — it's healthy)
    disease_mask = cv2.bitwise_and(
        disease_mask_raw,
        cv2.bitwise_not(green_mask)
    )

    # ── Morphological cleanup ─────────────────────────────────────────────
    # Remove tiny noise spots (salt-and-pepper noise)
    kernel       = np.ones((3, 3), np.uint8)
    disease_mask = cv2.morphologyEx(disease_mask, cv2.MORPH_OPEN,  kernel)
    disease_mask = cv2.morphologyEx(disease_mask, cv2.MORPH_CLOSE, kernel)
    green_mask   = cv2.morphologyEx(green_mask,   cv2.MORPH_OPEN,  kernel)

    # ── Count pixels ──────────────────────────────────────────────────────
    diseased_pixels = int(np.sum(disease_mask > 0))
    healthy_pixels  = int(np.sum(green_mask   > 0))
    background_pixels = total_pixels - diseased_pixels - healthy_pixels

    # Leaf pixels = healthy + diseased (excludes background)
    leaf_pixels     = diseased_pixels + healthy_pixels
    if leaf_pixels == 0:
        leaf_pixels = total_pixels   # fallback if segmentation fails

    infected_pct    = round((diseased_pixels / leaf_pixels) * 100, 1)
    healthy_pct     = round((healthy_pixels  / leaf_pixels) * 100, 1)
    background_pct  = round((background_pixels / total_pixels) * 100, 1)

    # Clip to valid range
    infected_pct = min(max(infected_pct, 0.0), 100.0)
    healthy_pct  = min(max(healthy_pct,  0.0), 100.0)

    severity = _classify_severity(infected_pct)

    severity_message = (
        f"{severity} infection — {infected_pct}% of leaf affected"
        if infected_pct > 0
        else "No disease detected — leaf appears healthy"
    )

    return {
        "severity":         severity,
        "infected_pct":     infected_pct,
        "healthy_pct":      healthy_pct,
        "background_pct":   background_pct,
        "total_pixels":     total_pixels,
        "diseased_pixels":  diseased_pixels,
        "healthy_pixels":   healthy_pixels,
        "severity_message": severity_message,
    }


def generate_severity_mask(image_input, save_path: str = None) -> str:
    """
    Generates a visual 3-panel image for report/demo:
      Panel 1: Original leaf
      Panel 2: Disease mask (white = diseased)
      Panel 3: Colour-coded overlay (red = disease, green = healthy)

    Returns base64-encoded PNG string.
    Poorvita can optionally include this in the /predict response.
    """
    img_bgr = _open_image(image_input)
    img_hsv = cv2.cvtColor(img_bgr, cv2.COLOR_BGR2HSV)
    img_rgb = cv2.cvtColor(img_bgr, cv2.COLOR_BGR2RGB)

    # Build masks
    green_mask   = cv2.inRange(img_hsv, GREEN_LOWER, GREEN_UPPER)
    brown_mask   = cv2.inRange(img_hsv, BROWN_LOWER, BROWN_UPPER)
    dark_mask    = cv2.inRange(img_hsv, DARK_LOWER,  DARK_UPPER)
    yellow_mask  = cv2.inRange(img_hsv, YELLOW_LOWER, YELLOW_UPPER)

    disease_raw  = cv2.bitwise_or(brown_mask, dark_mask)
    disease_raw  = cv2.bitwise_or(disease_raw, yellow_mask)
    disease_mask = cv2.bitwise_and(disease_raw, cv2.bitwise_not(green_mask))

    kernel       = np.ones((3, 3), np.uint8)
    disease_mask = cv2.morphologyEx(disease_mask, cv2.MORPH_OPEN,  kernel)
    disease_mask = cv2.morphologyEx(disease_mask, cv2.MORPH_CLOSE, kernel)
    green_mask   = cv2.morphologyEx(green_mask,   cv2.MORPH_OPEN,  kernel)

    # Colour-coded overlay
    overlay = img_rgb.copy()
    overlay[disease_mask > 0] = [220, 50,  50]   # red  = diseased
    overlay[green_mask   > 0] = [50,  200, 50]   # green = healthy

    # Build 3-panel image
    panel1 = img_rgb
    panel2 = cv2.cvtColor(disease_mask, cv2.COLOR_GRAY2RGB)
    panel3 = overlay

    combined = np.concatenate([panel1, panel2, panel3], axis=1)

    # Get severity info for title
    result = estimate_severity(image_input)
    title  = f"Severity: {result['severity']} — {result['infected_pct']}% infected"

    # Add title bar
    title_bar = np.ones((30, combined.shape[1], 3), dtype=np.uint8) * 240
    cv2.putText(
        title_bar, title, (10, 20),
        cv2.FONT_HERSHEY_SIMPLEX, 0.5, (50, 50, 50), 1, cv2.LINE_AA
    )
    combined = np.concatenate([title_bar, combined], axis=0)

    # Save and encode
    pil_img = Image.fromarray(combined.astype(np.uint8))
    if save_path:
        pil_img.save(save_path)
        print(f"Severity mask saved → {save_path}")

    buf = io.BytesIO()
    pil_img.save(buf, format="PNG")
    return base64.b64encode(buf.getvalue()).decode("utf-8")


# ── CLI test ──────────────────────────────────────────────────────────────────
if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage  : python severity.py <full_path_to_image>")
        print("Example: python severity.py \"R:\\...\\data\\Rice\\test\\Brownspot\\BROWNSPOT1_083.jpg\"")
        sys.exit(1)

    image_path = sys.argv[1]
    print(f"\n Estimating severity for: {image_path}")

    # ── Main result ───────────────────────────────────────────────────────
    result = estimate_severity(image_path)

    print("\n" + "=" * 56)
    print(f"  Severity      : {result['severity']}")
    print(f"  Infected      : {result['infected_pct']}%")
    print(f"  Healthy       : {result['healthy_pct']}%")
    print(f"  Total pixels  : {result['total_pixels']:,}")
    print(f"  Diseased px   : {result['diseased_pixels']:,}")
    print(f"  Message       : {result['severity_message']}")
    print("=" * 56)

    # ── Save visual mask ──────────────────────────────────────────────────
    out_path = os.path.join(_HERE, "severity_output.png")
    generate_severity_mask(image_path, save_path=out_path)
    print(f"\n 3-panel visual saved → {out_path}")
    print("   Open severity_output.png to see:")
    print("   [Original] | [Disease mask] | [Colour overlay]")

    # ── Show how Loss Agent uses this ─────────────────────────────────────
    print(f"\n Output passed to Loss Agent (Agent 4):")
    print(f"   severity    = '{result['severity']}'")
    print(f"   infected_pct = {result['infected_pct']}")