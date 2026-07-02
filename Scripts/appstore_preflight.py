#!/usr/bin/env python3
from __future__ import annotations
import argparse, json, plistlib, re, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
errors: list[str] = []
warnings: list[str] = []
parser = argparse.ArgumentParser(description="Run App Store preflight checks.")
parser.add_argument("--ci", action="store_true")
parser.add_argument("--strict", action="store_true", help="Return non-zero for warnings.")
args = parser.parse_args()

def require(path: str):
    if not (ROOT / path).exists():
        errors.append(f"Missing {path}")

def text(path: str) -> str:
    p = ROOT / path
    return p.read_text(encoding="utf-8") if p.exists() else ""

for path in [
    "Metadata/app_name.md", "Metadata/subtitle.md", "Metadata/description.md", "Metadata/keywords.md", "Metadata/review_notes.md", "Metadata/privacy_answers.md",
    "Sources/YCAppStarter/Resources/PrivacyInfo.xcprivacy", "StoreKit/YCAppStarter.storekit", "project.yml"
]:
    require(path)

try:
    plist = plistlib.loads((ROOT / "Sources/YCAppStarter/Info.plist").read_bytes())
    if not plist.get("CFBundleURLTypes"):
        warnings.append("Info.plist has no URL schemes; Magic Links or deep links may not work")
    gad_app_id = str(plist.get("GADApplicationIdentifier", ""))
    if "3940256099942544" in gad_app_id:
        warnings.append("Info.plist still uses the Google AdMob sample App ID")
    for key in ["YC_STARTER_ENVIRONMENT", "YC_STARTER_APP_GROUP_IDENTIFIER", "YC_STARTER_URL_SCHEME"]:
        if key not in plist:
            errors.append(f"Info.plist missing {key}")
except Exception as exc:
    errors.append(f"Info.plist invalid: {exc}")

try:
    app_ent = plistlib.loads((ROOT / "Sources/YCAppStarter/YCAppStarter.entitlements").read_bytes())
    widget_ent = plistlib.loads((ROOT / "Sources/YCAppStarterWidgets/YCAppStarterWidgets.entitlements").read_bytes())
    app_groups = set(app_ent.get("com.apple.security.application-groups", []))
    widget_groups = set(widget_ent.get("com.apple.security.application-groups", []))
    if app_groups != widget_groups:
        errors.append(f"App Group mismatch between app and widget entitlements: {app_groups} vs {widget_groups}")
    if any(group == "group.com.yuechuanlabs.ycappstarter" for group in app_groups):
        warnings.append("Entitlements still use the template App Group")
except Exception as exc:
    errors.append(f"Entitlements invalid: {exc}")

try:
    rc = json.loads((ROOT / "Sources/YCAppStarter/Resources/RemoteConfigDefaults.json").read_text(encoding="utf-8"))
    if rc.get("review_safe_mode_enabled") is not False:
        warnings.append("review_safe_mode_enabled should be false in committed defaults unless you intentionally ship a review-safe build")
    for key in ["ads_enabled", "ai_enabled", "live_activity_enabled"]:
        if rc.get(key) is True:
            warnings.append(f"{key} is enabled by default; confirm this is intentional for review")
    if rc.get("preflight_block_on_warnings") is True:
        args.strict = True
except Exception as exc:
    errors.append(f"RemoteConfigDefaults.json invalid: {exc}")

project = text("project.yml")
if "com.yuechuanlabs.ycappstarter" in project:
    warnings.append("project.yml still uses the template bundle identifier")
if "Config/Environments/Production.xcconfig" not in project:
    errors.append("project.yml does not wire Production.xcconfig")

secrets = text("Sources/YCAppStarter/Config/AppSecrets.swift")
if 'revenueCatAPIKey: ""' in secrets:
    warnings.append("RevenueCat API key is empty")
if 'supabaseURL: ""' in secrets or 'supabaseAnonKey: ""' in secrets:
    warnings.append("Supabase credentials are empty")
if "3940256099942544" in secrets:
    warnings.append("AppSecrets still contains Google AdMob sample IDs")
if not (ROOT / "Sources/YCAppStarter/Resources/GoogleService-Info.plist").exists():
    warnings.append("GoogleService-Info.plist is missing")

print("appstore_preflight")
print("=" * 18)
for e in errors: print(f"❌ {e}")
for w in warnings: print(f"⚠️ {w}")
print(f"Summary: {len(errors)} error(s), {len(warnings)} warning(s)")
sys.exit(1 if errors or ((args.ci or args.strict) and warnings) else 0)
