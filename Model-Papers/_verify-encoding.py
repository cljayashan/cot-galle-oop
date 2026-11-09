# -*- coding: utf-8 -*-
from pathlib import Path
import re

root = Path(__file__).resolve().parent
bad = []
for f in root.glob("Model-Paper-*.html"):
    t = f.read_text(encoding="utf-8")
    for i, line in enumerate(t.splitlines(), 1):
        if re.search(r"[\u00e2\u20ac]|â€", line):
            bad.append((f.name, i, line.strip()[:140]))
print("mojibake lines:", len(bad))
for b in bad[:20]:
    print(b)

# show key samples
p = (root / "Model-Paper-01-Easy.html").read_text(encoding="utf-8")
for needle in ["Loops", 'prints "Hello"', "same class", ">=75"]:
    for line in p.splitlines():
        if needle in line:
            print("OK:", line.strip())
            break
