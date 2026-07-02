#!/usr/bin/env python3
"""Configure Supabase URL and publishable/anon key in AppSecrets.swift."""
import argparse
from pathlib import Path
import plistlib

ROOT = Path(__file__).resolve().parents[1]
SECRETS = ROOT / "Sources/YCAppStarter/Config/AppSecrets.swift"
INFO_PLIST = ROOT / "Sources/YCAppStarter/Info.plist"

def replace_assignment(text: str, name: str, value: str) -> str:
    import re
    pattern = rf'{name}: "[^"]*"'
    replacement = f'{name}: "{value}"'
    if re.search(pattern, text):
        return re.sub(pattern, replacement, text)
    raise SystemExit(f"Could not find assignment for {name} in {SECRETS}")

def main() -> int:
    parser = argparse.ArgumentParser(description="Configure Supabase for YCAppStarter.")
    parser.add_argument("--url", required=True, help="Supabase project URL, for example https://xxx.supabase.co")
    parser.add_argument("--anon-key", required=True, help="Supabase publishable or legacy anon key")
    parser.add_argument("--redirect-scheme", default="ycappstarter", help="Custom URL scheme for auth deep links")
    args = parser.parse_args()

    text = SECRETS.read_text(encoding="utf-8")
    text = replace_assignment(text, "supabaseURL", args.url)
    text = replace_assignment(text, "supabaseAnonKey", args.anon_key)
    text = replace_assignment(text, "supabaseRedirectScheme", args.redirect_scheme)
    SECRETS.write_text(text, encoding="utf-8")

    with INFO_PLIST.open("rb") as f:
        plist = plistlib.load(f)
    plist["CFBundleURLTypes"] = [{
        "CFBundleTypeRole": "Editor",
        "CFBundleURLName": "YCAppStarter Auth",
        "CFBundleURLSchemes": [args.redirect_scheme],
    }]
    with INFO_PLIST.open("wb") as f:
        plistlib.dump(plist, f)

    print("Supabase config updated in AppSecrets.swift and Info.plist")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
