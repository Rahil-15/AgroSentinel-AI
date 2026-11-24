"""
test_models_agents.py  -  AgroSentinel AI 
===========================================================================
Tests the detector, saliency (gradcam.py) and severity agents.
Run from the models/ folder (next to predict_single.py, gradcam.py, severity.py, labels.json, data/):
    python test_models_agents.py
Optional: put leaf photos of UNSUPPORTED crops (wheat, mango, ...) in  test_assets/unsupported/
Note: predict_single.py loads crop_model.h5. To test another model, temporarily point MODEL_PATH
      in predict_single.py at it (e.g. crop_model_central_ft.h5).

Outputs: test_results_models.csv, test_outputs/ (saliency image, severity images, detector_samples.csv)
Tests whose files/libraries are missing are marked SKIP instead of failing.
"""
import os, sys, io, re, csv, json, time, base64, random, statistics
import numpy as np
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
OUT = os.path.join(HERE, "test_outputs"); os.makedirs(OUT, exist_ok=True)
DATA = os.path.join(HERE, "data")
CROPS = ["Corn (Maize)", "Potato", "Rice", "Tomato"]
EXT = (".jpg", ".jpeg", ".png", ".bmp", ".tif", ".tiff")

RESULTS = []
def _rec(tid, desc, exp, act, status, note=""):
    RESULTS.append((tid, desc, str(exp), str(act), status, note))
    print(f"[{status}] {tid}: {desc}\n        expected: {exp} | actual: {act}" + (f"\n        note: {note}" if note else ""))
def check(tid, desc, exp, act, ok, note=""): _rec(tid, desc, exp, act, "PASS" if ok else "FAIL", note)
def skip(tid, desc, why): _rec(tid, desc, "-", "-", "SKIP", why)
def info(tid, desc, act, note=""): _rec(tid, desc, "(recorded only)", act, "INFO", note)
def finish(name):
    with open(os.path.join(HERE, name), "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f); w.writerow(["Test ID", "Description", "Expected", "Actual", "Status", "Note"]); w.writerows(RESULTS)
    c = lambda s: sum(r[4] == s for r in RESULTS)
    print(f"\nPASS {c('PASS')} | FAIL {c('FAIL')} | SKIP {c('SKIP')} | INFO {c('INFO')}  ->  {name}")

def norm(s): return re.sub(r"[_\s]+", " ", s).strip().lower()
def png_bytes(arr):
    b = io.BytesIO(); Image.fromarray(arr).save(b, "PNG"); return b.getvalue()

def test_images(per_class=3, seed=42):
    rng, out = random.Random(seed), []
    for crop in CROPS:
        base = next((os.path.join(DATA, crop, s) for s in ("Test", "test") if os.path.isdir(os.path.join(DATA, crop, s))), None)
        if not base: continue
        for cls in sorted(os.listdir(base)):
            d = os.path.join(base, cls)
            if not os.path.isdir(d): continue
            files = [os.path.join(r, f) for r, _, fs in os.walk(d) for f in fs if f.lower().endswith(EXT)]
            rng.shuffle(files)
            out += [(crop, cls, f) for f in files[:per_class]]
    return out

SAMPLES = test_images()

# ---------------- optional imports ----------------
try:
    import predict_single as PS
    HAVE_MODEL = True
except Exception as e:
    HAVE_MODEL, PS_ERR = False, str(e)[:80]
try:
    import gradcam as GC
    HAVE_GC = True
except Exception as e:
    HAVE_GC, GC_ERR = False, str(e)[:80]
try:
    import severity as SV
    HAVE_SV = True
except Exception as e:
    HAVE_SV, SV_ERR = False, str(e)[:80]

# ================= DETECTOR =================
if HAVE_MODEL and SAMPLES:
    try:
        model, labels = PS.load_model_once()
        check("M-01", "Model and labels load; output size equals number of classes", "16 and 16",
              f"{model.output_shape[-1]} and {len(labels)}", model.output_shape[-1] == 16 == len(labels))
    except Exception as e:
        check("M-01", "Model and labels load", "loads", str(e)[:100], False)

    rows, per_crop = [], {}
    for crop, cls, path in SAMPLES:
        r = PS.predict_image(path)
        ok = norm(crop.replace(" (Maize)", "")) == norm(r["crop"]) and norm(cls) == norm(r["disease"])
        rows.append([os.path.relpath(path, HERE), f"{crop} / {cls}", f"{r['crop']} / {r['disease']}", r["confidence"], ok])
        per_crop.setdefault(crop, []).append(ok)
    with open(os.path.join(OUT, "detector_samples.csv"), "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f); w.writerow(["file", "expected", "predicted", "confidence", "correct"]); w.writerows(rows)
    acc = sum(r[4] for r in rows) / len(rows)
    detail = ", ".join(f"{c}: {sum(v)}/{len(v)}" for c, v in per_crop.items())
    check("M-02", f"Detector on {len(rows)} sampled test images (3 per class)", ">= 80% correct (pipeline sanity check)",
          f"{acc:.0%} ({detail})", acc >= 0.80, "see test_outputs/detector_samples.csv; full accuracy comes from evaluate_clean.py")

    r = PS.predict_image(SAMPLES[0][2])
    check("M-03", "Prediction has all expected fields", "crop, disease, confidence, is_healthy, top3(3), is_supported",
          sorted(r), all(k in r for k in ("crop", "disease", "confidence", "is_healthy", "top3", "is_supported")) and len(r["top3"]) == 3)

    p = SAMPLES[0][2]
    r1, r2 = PS.predict_image(p), PS.predict_image(open(p, "rb").read())
    check("M-04", "Same result from a file path and from raw bytes (the FastAPI path)", "identical",
          f"{r1['disease']} {r1['confidence']} vs {r2['disease']} {r2['confidence']}",
          r1["disease"] == r2["disease"] and abs(r1["confidence"] - r2["confidence"]) < 1e-4)

    ts = []
    for _ in range(5):
        t0 = time.time(); PS.predict_image(p); ts.append(time.time() - t0)
    check("M-05", "Prediction time per image after warm-up (CPU)", "< 5 s", f"median {statistics.median(ts):.2f} s", statistics.median(ts) < 5)

    unsup = os.path.join(HERE, "test_assets", "unsupported")
    files = [os.path.join(unsup, f) for f in os.listdir(unsup) if f.lower().endswith(EXT)] if os.path.isdir(unsup) else []
    if files:
        rej = sum(PS.predict_image(f).get("is_supported") is False for f in files)
        check("M-06", f"Unsupported-crop leaves are rejected ({len(files)} images)", ">= 80% rejected", f"{rej}/{len(files)}", rej / len(files) >= 0.8,
              "if low, raise CONFIDENCE_THRESHOLD in predict_single.py")
    else:
        skip("M-06", "Unsupported-crop leaves are rejected", "add photos to test_assets/unsupported/")

    for name, arr in [("blank_gray", np.full((224, 224, 3), 128, np.uint8)),
                      ("random_noise", np.random.RandomState(0).randint(0, 255, (224, 224, 3), dtype=np.uint8))]:
        r = PS.predict_image(png_bytes(arr))
        info(f"M-07-{name}", f"Non-leaf image ({name})", f"{r['crop']} / {r['disease']} / conf {r['confidence']} / supported={r['is_supported']}",
             "shows the limits of the confidence-threshold rejection")
else:
    why = "no model/TensorFlow here" if not HAVE_MODEL else "no data/ folder with Test images"
    for tid, d in [("M-01", "Model loads"), ("M-02", "Detector on sampled test images"), ("M-03", "Prediction fields"),
                   ("M-04", "Path vs bytes"), ("M-05", "Prediction time"), ("M-06", "Unsupported crops rejected"), ("M-07", "Non-leaf images")]:
        skip(tid, d, why)

# ================= SEVERITY (OpenCV) =================
if HAVE_SV:
    green = np.zeros((224, 224, 3), np.uint8); green[:] = (34, 139, 34)
    half = green.copy(); half[:, 112:] = (139, 69, 19)
    brown = np.zeros((224, 224, 3), np.uint8); brown[:] = (139, 69, 19)
    r = SV.estimate_severity(png_bytes(green))
    check("S-01", "All-green synthetic leaf -> 0% infected, Early", "0%, Early", f"{r['infected_pct']}%, {r['severity']}", r["infected_pct"] <= 1 and r["severity"] == "Early")
    r = SV.estimate_severity(png_bytes(half))
    check("S-02", "Half green / half brown synthetic leaf -> about 50%, Severe", "40-60%, Severe", f"{r['infected_pct']}%, {r['severity']}",
          40 <= r["infected_pct"] <= 60 and r["severity"] == "Severe")
    r = SV.estimate_severity(png_bytes(brown))
    check("S-03", "All-brown synthetic leaf -> about 100%, Severe", ">= 90%, Severe", f"{r['infected_pct']}%, {r['severity']}", r["infected_pct"] >= 90 and r["severity"] == "Severe")

    bad = []
    for v in (0.0, 14.9, 15.0, 39.9, 40.0, 100.0):
        want = "Early" if v < 15 else "Moderate" if v < 40 else "Severe"
        if SV._classify_severity(v) != want: bad.append(v)
    check("S-04", "Severity label boundaries (15% and 40%)", "all correct", bad or "all correct", not bad)

    healthy = [s for s in SAMPLES if "healthy" in s[1].lower()][:10]
    sick = [s for s in SAMPLES if "healthy" not in s[1].lower()][:10]
    if healthy and sick:
        mh = statistics.mean(SV.estimate_severity(p)["infected_pct"] for _, _, p in healthy)
        ms = statistics.mean(SV.estimate_severity(p)["infected_pct"] for _, _, p in sick)
        check("S-05", "Diseased leaves show a higher infected % than healthy leaves (real images)", "diseased mean > healthy mean",
              f"healthy {mh:.1f}% vs diseased {ms:.1f}%", ms > mh)
        crop, cls, p = sick[0]
        open(os.path.join(OUT, "severity_sample.png"), "wb").write(base64.b64decode(SV.generate_severity_mask(p)))
        check("S-06", "3-panel severity image is produced", "PNG saved", "test_outputs/severity_sample.png", True)
    else:
        skip("S-05", "Real-image severity comparison", "needs data/ folder")
        skip("S-06", "3-panel severity image", "needs data/ folder")
else:
    for tid in ("S-01", "S-02", "S-03", "S-04", "S-05", "S-06"):
        skip(tid, "Severity agent", SV_ERR)

# ================= SALIENCY =================
if HAVE_GC and HAVE_MODEL and SAMPLES:
    p = SAMPLES[0][2]
    b64 = GC.generate_gradcam(open(p, "rb").read())
    try:
        img = Image.open(io.BytesIO(base64.b64decode(b64))); img.load(); ok = img.size[0] > 0
        img.save(os.path.join(OUT, "saliency_sample.png"))
    except Exception:
        ok = False
    check("G-01", "Saliency agent returns a decodable PNG (base64)", "valid image", "test_outputs/saliency_sample.png" if ok else "not an image", ok)
    d = GC.generate_gradcam_with_info(p)
    check("G-02", "Saliency info matches the detector's prediction", "same disease", f"{d['disease']}", norm(d["disease"]) == norm(PS.predict_image(p)["disease"]))
else:
    skip("G-01", "Saliency image is produced", "no model/TensorFlow here")
    skip("G-02", "Saliency matches detector", "no model/TensorFlow here")

finish("test_results_models.csv")