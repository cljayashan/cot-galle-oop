# -*- coding: utf-8 -*-
from pathlib import Path

root = Path(__file__).resolve().parent

# Closing curly-quote mojibake was wrongly turned into '-'. Restore ASCII quotes.
fixes = [
    ('prints "Hello- exactly', 'prints "Hello" exactly'),
    ('same class-?', 'same class"?'),
    ('"LibraryItemOps- interface', '"LibraryItemOps" interface'),
    ('"Campus Lost &amp; Found-.', '"Campus Lost &amp; Found".'),
    ('"sorting references-.', '"sorting references".'),
]

# Also fix build script source strings if present
script_fixes = [
    ('prints "Hello- exactly', 'prints "Hello" exactly'),
    ("prints 'Hello- exactly", 'prints "Hello" exactly'),
]

for f in list(root.glob("Model-Paper-*.html")) + [root / "build-model-papers.ps1"]:
    text = f.read_text(encoding="utf-8")
    orig = text
    for a, b in fixes + script_fixes:
        text = text.replace(a, b)
    if text != orig:
        f.write_text(text, encoding="utf-8", newline="\n")
        print("Fixed quotes in", f.name)
    else:
        print("No quote fixes needed:", f.name)

# Final scan for broken pattern: opening " without closing before - punctuation
import re
for f in root.glob("Model-Paper-*.html"):
    t = f.read_text(encoding="utf-8")
    for m in re.finditer(r'"[^"\n]{0,60}-[\s.?]', t):
        print("CHECK", f.name, ":", m.group())
