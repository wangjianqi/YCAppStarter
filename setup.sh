#!/usr/bin/env bash
set -euo pipefail

APP_NAME=""
BUNDLE_ID=""
ACCENT_HEX=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --app-name)
      APP_NAME="$2"; shift 2 ;;
    --bundle-id)
      BUNDLE_ID="$2"; shift 2 ;;
    --accent)
      ACCENT_HEX="$2"; shift 2 ;;
    *)
      echo "Unknown argument: $1"; exit 1 ;;
  esac
done

if [[ -n "$APP_NAME" ]]; then
  python3 Scripts/setup_config.py --app-name "$APP_NAME"
fi

if [[ -n "$BUNDLE_ID" ]]; then
  python3 Scripts/setup_config.py --bundle-id "$BUNDLE_ID"
fi

if [[ -n "$ACCENT_HEX" ]]; then
  python3 Scripts/setup_config.py --accent "$ACCENT_HEX"
fi

echo "YCAppStarter V2 setup completed. Run: xcodegen generate"
