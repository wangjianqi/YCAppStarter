#!/usr/bin/env python3
import argparse
from pathlib import Path
import plistlib

ROOT = Path(__file__).resolve().parents[1]
INFO = ROOT / "Sources/YCAppStarter/Info.plist"
ENT = ROOT / "Sources/YCAppStarter/YCAppStarter.entitlements"
SECRETS = ROOT / "Sources/YCAppStarter/Config/AppSecrets.swift"


def replace_literal(text: str, field: str, value: str) -> str:
    import re
    return re.sub(rf'{field}: "[^"]*"', f'{field}: "{value}"', text)


def main() -> int:
    parser = argparse.ArgumentParser(description="Configure APNs/Firebase Messaging basics for YCAppStarter V2.8.")
    parser.add_argument("--environment", choices=["development", "production"], default="development")
    parser.add_argument("--bundle-id", default="", help="Optional push topic bundle id. Defaults to PRODUCT_BUNDLE_IDENTIFIER.")
    args = parser.parse_args()

    ent = plistlib.loads(ENT.read_bytes())
    ent["aps-environment"] = args.environment
    ENT.write_bytes(plistlib.dumps(ent, sort_keys=False))

    plist = plistlib.loads(INFO.read_bytes())
    plist["FirebaseMessagingAutoInitEnabled"] = True
    INFO.write_bytes(plistlib.dumps(plist, sort_keys=False))

    text = SECRETS.read_text(encoding="utf-8")
    text = replace_literal(text, "apnsEnvironment", args.environment)
    if args.bundle_id:
        text = replace_literal(text, "pushTopicBundleID", args.bundle_id)
    SECRETS.write_text(text, encoding="utf-8")

    print(f"Configured push environment: {args.environment}")
    if args.bundle_id:
        print(f"Configured push topic bundle id: {args.bundle_id}")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
