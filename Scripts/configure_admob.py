#!/usr/bin/env python3
"""Configure AdMob App ID and default ad unit IDs for YCAppStarter.

This script updates Info.plist and Config/AppSecrets.swift. It intentionally keeps the
runtime policy controlled by RemoteConfigDefaults.json / Firebase Remote Config.
"""
import argparse
import plistlib
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
INFO_PLIST = ROOT / "Sources/YCAppStarter/Info.plist"
SECRETS = ROOT / "Sources/YCAppStarter/Config/AppSecrets.swift"

APP_ID_PATTERN = re.compile(r"^ca-app-pub-\d{16}~\d+$")
AD_UNIT_PATTERN = re.compile(r"^ca-app-pub-\d{16}/\d+$")


def replace_swift_value(text: str, key: str, value: str) -> str:
    pattern = re.compile(rf"({key}:\s*)\"[^\"]*\"")
    return pattern.sub(rf"\1\"{value}\"", text)


def main() -> int:
    parser = argparse.ArgumentParser(description="Configure AdMob IDs for YCAppStarter.")
    parser.add_argument("--app-id", required=True, help="AdMob app ID, e.g. ca-app-pub-1234567890123456~1234567890")
    parser.add_argument("--banner", required=True, help="Banner ad unit ID")
    parser.add_argument("--interstitial", required=True, help="Interstitial ad unit ID")
    parser.add_argument("--rewarded", required=True, help="Rewarded ad unit ID")
    args = parser.parse_args()

    validations = [
        ("app-id", args.app_id, APP_ID_PATTERN),
        ("banner", args.banner, AD_UNIT_PATTERN),
        ("interstitial", args.interstitial, AD_UNIT_PATTERN),
        ("rewarded", args.rewarded, AD_UNIT_PATTERN),
    ]
    errors = [f"Invalid {label}: {value}" for label, value, pattern in validations if not pattern.match(value)]
    if errors:
        for error in errors:
            print(f"[ERR] {error}")
        return 1

    if not INFO_PLIST.exists() or not SECRETS.exists():
        print("[ERR] Expected Info.plist and AppSecrets.swift to exist.")
        return 1

    with INFO_PLIST.open("rb") as f:
        plist = plistlib.load(f)
    plist["GADApplicationIdentifier"] = args.app_id
    if "SKAdNetworkItems" not in plist:
        plist["SKAdNetworkItems"] = [{"SKAdNetworkIdentifier": "cstr6suwn9.skadnetwork"}]
    with INFO_PLIST.open("wb") as f:
        plistlib.dump(plist, f, sort_keys=False)

    secrets_text = SECRETS.read_text(encoding="utf-8")
    secrets_text = replace_swift_value(secrets_text, "admobAppID", args.app_id)
    secrets_text = replace_swift_value(secrets_text, "admobBannerAdUnitID", args.banner)
    secrets_text = replace_swift_value(secrets_text, "admobInterstitialAdUnitID", args.interstitial)
    secrets_text = replace_swift_value(secrets_text, "admobRewardedAdUnitID", args.rewarded)
    SECRETS.write_text(secrets_text, encoding="utf-8")

    print("[OK] Updated Info.plist and AppSecrets.swift with AdMob IDs.")
    print("[INFO] Keep Google test IDs during development; use production IDs only when ready to ship.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
