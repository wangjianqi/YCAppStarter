#!/usr/bin/env python3
from pathlib import Path
import plistlib

ROOT = Path(__file__).resolve().parents[1]
INFO = ROOT / "Sources/YCAppStarter/Info.plist"
SECRETS = ROOT / "Sources/YCAppStarter/Config/AppSecrets.swift"

errors = []
warnings = []
plist = plistlib.loads(INFO.read_bytes())
schemes = []
for item in plist.get("CFBundleURLTypes", []):
    schemes.extend(item.get("CFBundleURLSchemes", []))
if not schemes:
    errors.append("No CFBundleURLSchemes found in Info.plist.")
text = SECRETS.read_text(encoding="utf-8")
if 'supabaseRedirectScheme: ""' in text:
    warnings.append("supabaseRedirectScheme is empty in AppSecrets.swift.")
if "DeepLinkRouter.swift" not in "\n".join(p.name for p in (ROOT / "Sources/YCAppStarter/Core/DeepLink").glob("*.swift")):
    errors.append("DeepLinkRouter.swift is missing.")

print("validate_deep_links")
print("=" * 20)
for e in errors:
    print(f"ERROR: {e}")
for w in warnings:
    print(f"WARNING: {w}")
print(f"Summary: {len(errors)} error(s), {len(warnings)} warning(s)")
raise SystemExit(1 if errors else 0)
