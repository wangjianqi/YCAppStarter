#!/usr/bin/env python3
from __future__ import annotations
import argparse
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser()
parser.add_argument("--output", default="build/release-notes.md")
args = parser.parse_args()
version = (ROOT / ".starter-version").read_text(encoding="utf-8").strip()
content = f"""# YCAppStarter {version} Release Notes

## Summary
- Production Hardening Kit added.
- CI, StoreKit Test, preflight scripts, analytics event catalog and release packaging templates included.

## Validation
Run:

```bash
python3 Scripts/ycstarter.py validate
```
"""
out = ROOT / args.output
out.parent.mkdir(parents=True, exist_ok=True)
out.write_text(content, encoding="utf-8")
print(out)
