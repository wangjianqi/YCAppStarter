#!/usr/bin/env python3
"""Simple app-ads.txt validator.

Usage:
  python3 Scripts/check_app_ads_txt.py --domain yuechuanai.cn --publisher pub-0000000000000000
  python3 Scripts/check_app_ads_txt.py --file ./app-ads.txt --publisher pub-0000000000000000
"""
import argparse
import sys
import urllib.request
from pathlib import Path


def fetch(domain: str) -> tuple[str, str]:
    domain = domain.replace("https://", "").replace("http://", "").strip("/")
    url = f"https://{domain}/app-ads.txt"
    req = urllib.request.Request(url, headers={"User-Agent": "Google-adstxt"})
    with urllib.request.urlopen(req, timeout=10) as response:  # nosec - developer tool
        return url, response.read().decode("utf-8", errors="replace")


def main() -> int:
    parser = argparse.ArgumentParser(description="Validate app-ads.txt content for an expected AdMob publisher ID.")
    parser.add_argument("--domain", help="Developer website domain, for example yuechuanai.cn")
    parser.add_argument("--file", help="Local app-ads.txt file")
    parser.add_argument("--publisher", required=True, help="Expected publisher ID, for example pub-0000000000000000")
    args = parser.parse_args()

    if not args.domain and not args.file:
        parser.error("Provide either --domain or --file")

    try:
        if args.file:
            source = args.file
            content = Path(args.file).read_text(encoding="utf-8")
        else:
            source, content = fetch(args.domain)
    except Exception as exc:  # noqa: BLE001
        print(f"[ERR] Unable to read app-ads.txt: {exc}")
        return 1

    normalized = content.replace(" ", "")
    expected_google = f"google.com,{args.publisher},DIRECT"
    expected_present = expected_google in normalized

    print("YCAppStarter app-ads.txt Check")
    print("=" * 32)
    print(f"Source: {source}")
    if expected_present:
        print(f"[OK] Found expected Google AdMob line: {expected_google}")
    else:
        print(f"[ERR] Missing expected Google AdMob line: {expected_google}")
        print("      fix: Add the exact line to app-ads.txt at the root of the developer website.")
    if "google.com" not in normalized:
        print("[WARN] No google.com seller line found.")
    if not content.strip().endswith("\n"):
        print("[INFO] app-ads.txt does not end with a newline. This is usually tolerated but easy to fix.")
    return 0 if expected_present else 1


if __name__ == "__main__":
    raise SystemExit(main())
