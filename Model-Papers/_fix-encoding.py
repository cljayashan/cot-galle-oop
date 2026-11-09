# -*- coding: utf-8 -*-
"""Fix mojibake / smart punctuation in model papers."""
from pathlib import Path
import re
from collections import Counter

root = Path(__file__).resolve().parent

files = list(root.glob("Model-Paper-*.html"))
files += [
    root / "build-model-papers.ps1",
    root / "_papers-meta.json",
    root / "index.html",
]

# Discover sequences first
seqs = Counter()
for f in root.glob("Model-Paper-*.html"):
    t = f.read_text(encoding="utf-8")
    for m in re.finditer(r"[\u00e2][^\x00-\x7F]{0,4}", t):
        seqs[m.group()] += 1

print("Sequences before fix:")
for s, c in seqs.most_common(40):
    print(f"  {c:4d}  {s!r}  {[hex(ord(x)) for x in s]}")

# Build replacement map from discovered patterns + known smart chars
# CP1252 mis-decode of UTF-8 punctuation:
# — E2 80 94 -> U+00E2 U+20AC U+201D
# – E2 80 93 -> U+00E2 U+20AC U+201C  (0x93 is U+201C in cp1252? actually 0x93 is ‘ U+2018... check)
# Actually standard:
# 0x93 -> U+201C “
# 0x94 -> U+201D ”
# 0x98 -> U+02DC ˜  OR U+2018 depending
# 0x99 -> U+2122 ™
# 0x9C -> U+0153 œ
# 0x9D -> U+009D or ”
# For ≥ E2 89 A5 -> â‰¥ (U+00E2 U+2030 U+00A5)

repl = {
    "\u00e2\u20ac\u201d": "-",   # â€”  (em dash mojibake) — MUST be before shorter right-quote maps if overlapping
    "\u00e2\u20ac\u201c": "-",   # â€“  (en dash mojibake often)
    "\u00e2\u20ac\u2122": "'",   # â€™
    "\u00e2\u20ac\u0153": '"',   # â€œ
    "\u00e2\u20ac\u02dc": "'",   # â€˜
    "\u00e2\u2030\u00a5": ">=",  # â‰¥
    # Real unicode
    "\u2014": "-",
    "\u2013": "-",
    "\u2018": "'",
    "\u2019": "'",
    "\u201c": '"',
    "\u201d": '"',
    "\u2026": "...",
    "\u2265": ">=",
}

# Also map any discovered â… sequences not covered: replace with ASCII dash/quote heuristic
for s in list(seqs):
    if s not in repl:
        # default: drop to hyphen for dash-like, else strip high chars carefully
        if "\u20ac" in s:
            repl[s] = "-"

changed_files = []
for f in files:
    if not f.exists():
        continue
    text = f.read_text(encoding="utf-8")
    original = text
    # Apply longer keys first
    for k in sorted(repl.keys(), key=len, reverse=True):
        text = text.replace(k, repl[k])
    if text != original:
        f.write_text(text, encoding="utf-8", newline="\n")
        changed_files.append(f.name)
        print(f"Fixed: {f.name}")
    else:
        print(f"OK: {f.name}")

# Verify
seqs2 = Counter()
for f in root.glob("Model-Paper-*.html"):
    t = f.read_text(encoding="utf-8")
    for m in re.finditer(r"[\u00e2][^\x00-\x7F]{0,4}", t):
        seqs2[m.group()] += 1
    for line in t.splitlines():
        if "Loops" in line:
            print("SAMPLE:", line.strip())

print("Remaining â-sequences:", dict(seqs2))
print("Changed:", len(changed_files), "files")
