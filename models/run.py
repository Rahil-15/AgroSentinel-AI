import os, re
root = r"R:\Major project\AgroSentinel AI\models\data"
base = lambda f: re.sub(r'_(flip(TB|LR)|\d+deg)(?=\.[^.]+$)', '', f, flags=re.I).lower()
seen, hits, total = set(), 0, 0
for d, _, fs in os.walk(root):
    if re.search(r'[\\/](train|val)([\\/]|$)', d, re.I):
        seen.update(base(f) for f in fs)
for d, _, fs in os.walk(root):
    if re.search(r'[\\/]test([\\/]|$)', d, re.I):
        for f in fs:
            total += 1; hits += base(f) in seen
print(hits, "of", total, "test files share a base name with a train/val file")