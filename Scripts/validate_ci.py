#!/usr/bin/env python3
from __future__ import annotations
import os, sys
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
errors: list[str] = []
warnings: list[str] = []
for script in ["ci_scripts/ci_post_clone.sh", "ci_scripts/ci_pre_xcodebuild.sh", "ci_scripts/ci_post_xcodebuild.sh"]:
    path = ROOT / script
    if not path.exists():
        errors.append(f"Missing {script}")
    elif not os.access(path, os.X_OK):
        errors.append(f"{script} is not executable")
project = (ROOT / "project.yml").read_text(encoding="utf-8") if (ROOT / "project.yml").exists() else ""
if "YCAppStarterTests" not in project:
    errors.append("project.yml is missing YCAppStarterTests target")
if "MARKETING_VERSION: 3.0.0" not in project:
    warnings.append("project.yml marketing version is not 3.0.0")
print("validate_ci")
print("=" * 11)
for e in errors: print(f"❌ {e}")
for w in warnings: print(f"⚠️ {w}")
print(f"Summary: {len(errors)} error(s), {len(warnings)} warning(s)")
sys.exit(1 if errors else 0)
