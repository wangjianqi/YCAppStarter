#!/usr/bin/env python3
from __future__ import annotations
import argparse, plistlib, sys, json
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
errors: list[str] = []
warnings: list[str] = []
parser = argparse.ArgumentParser(description="Run App Store preflight checks.")
parser.add_argument("--ci", action="store_true")
args = parser.parse_args()

def require(path: str):
    if not (ROOT / path).exists():
        errors.append(f"Missing {path}")

for path in [
    "Metadata/app_name.md", "Metadata/subtitle.md", "Metadata/description.md", "Metadata/keywords.md", "Metadata/review_notes.md", "Metadata/privacy_answers.md",
    "Sources/YCAppStarter/Resources/PrivacyInfo.xcprivacy", "StoreKit/YCAppStarter.storekit", "project.yml"
]:
    require(path)
try:
    plist = plistlib.loads((ROOT / "Sources/YCAppStarter/Info.plist").read_bytes())
    if not plist.get("CFBundleURLTypes"):
        warnings.append("Info.plist has no URL schemes; Magic Links or deep links may not work")
except Exception as exc:
    errors.append(f"Info.plist invalid: {exc}")
try:
    rc = json.loads((ROOT / "Sources/YCAppStarter/Resources/RemoteConfigDefaults.json").read_text(encoding="utf-8"))
    if rc.get("review_safe_mode_enabled") is not False:
        warnings.append("review_safe_mode_enabled should be false in committed defaults unless you intentionally ship a review-safe build")
    for key in ["ads_enabled", "ai_enabled", "live_activity_enabled"]:
        if rc.get(key) is True:
            warnings.append(f"{key} is enabled by default; confirm this is intentional for review")
except Exception as exc:
    errors.append(f"RemoteConfigDefaults.json invalid: {exc}")
print("appstore_preflight")
print("=" * 18)
for e in errors: print(f"❌ {e}")
for w in warnings: print(f"⚠️ {w}")
print(f"Summary: {len(errors)} error(s), {len(warnings)} warning(s)")
sys.exit(1 if errors or (args.ci and errors) else 0)
