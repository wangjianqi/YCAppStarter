#!/usr/bin/env python3
from __future__ import annotations
import subprocess, sys
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
commands = [
    ["python3", "Scripts/validate_remote_config.py"],
    ["python3", "Scripts/validate_storekit.py"],
    ["python3", "Scripts/validate_ci.py"],
    ["python3", "Scripts/appstore_preflight.py"],
    ["python3", "Scripts/ycstarter_doctor.py"],
]
failed = 0
for cmd in commands:
    print("$", " ".join(cmd))
    result = subprocess.run(cmd, cwd=ROOT)
    if result.returncode != 0:
        failed += 1
print(f"validate_production: {failed} failed command(s)")
sys.exit(1 if failed else 0)
