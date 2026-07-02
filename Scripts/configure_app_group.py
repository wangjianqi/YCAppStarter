#!/usr/bin/env python3
from __future__ import annotations
import argparse, plistlib, re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
APP_ENT = ROOT / "Sources/YCAppStarter/YCAppStarter.entitlements"
WIDGET_ENT = ROOT / "Sources/YCAppStarterWidgets/YCAppStarterWidgets.entitlements"
SECRETS = ROOT / "Sources/YCAppStarter/Config/AppSecrets.swift"
WIDGET = ROOT / "Sources/YCAppStarterWidgets/StarterStatusWidget.swift"
PROJECT = ROOT / "project.yml"

def set_app_group(path: Path, group: str):
    data = plistlib.loads(path.read_bytes())
    data["com.apple.security.application-groups"] = [group]
    path.write_bytes(plistlib.dumps(data, sort_keys=False))

def replace_text(path: Path, pattern: str, replacement: str):
    text = path.read_text(encoding="utf-8")
    text = re.sub(pattern, replacement, text)
    path.write_text(text, encoding="utf-8")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Configure shared App Group for app + widget extension.")
    parser.add_argument("--app-group", required=True, help="Example: group.com.yourcompany.yourapp")
    parser.add_argument("--widget-bundle-id", help="Optional widget extension bundle id")
    args = parser.parse_args()

    if not args.app_group.startswith("group."):
        raise SystemExit("App Group must start with group.")

    set_app_group(APP_ENT, args.app_group)
    set_app_group(WIDGET_ENT, args.app_group)
    replace_text(SECRETS, r'appGroupIdentifier: "[^"]*"', f'appGroupIdentifier: "{args.app_group}"')
    replace_text(WIDGET, r'UserDefaults\(suiteName: "[^"]*"\)', f'UserDefaults(suiteName: "{args.app_group}")')

    if args.widget_bundle_id:
        replace_text(PROJECT, r'PRODUCT_BUNDLE_IDENTIFIER: [\w\.]+\.widgets', f'PRODUCT_BUNDLE_IDENTIFIER: {args.widget_bundle_id}')

    print(f"Configured App Group: {args.app_group}")
