#!/usr/bin/env bash
set -euo pipefail

APP_NAME=""
BUNDLE_ID=""
WIDGET_BUNDLE_ID=""
APP_GROUP=""
URL_SCHEME=""
ACCENT_HEX=""
ADMOB_APP_ID=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --app-name)
      APP_NAME="$2"; shift 2 ;;
    --bundle-id)
      BUNDLE_ID="$2"; shift 2 ;;
    --widget-bundle-id)
      WIDGET_BUNDLE_ID="$2"; shift 2 ;;
    --app-group)
      APP_GROUP="$2"; shift 2 ;;
    --url-scheme)
      URL_SCHEME="$2"; shift 2 ;;
    --accent)
      ACCENT_HEX="$2"; shift 2 ;;
    --admob-app-id)
      ADMOB_APP_ID="$2"; shift 2 ;;
    *)
      echo "Unknown argument: $1"; exit 1 ;;
  esac
done

if [[ -z "$BUNDLE_ID" ]]; then
  echo "Missing required --bundle-id. Example: ./setup.sh --app-name "My App" --bundle-id com.company.myapp"
  exit 1
fi

CMD=(python3 Scripts/setup_config.py init --bundle-id "$BUNDLE_ID")
[[ -n "$APP_NAME" ]] && CMD+=(--app-name "$APP_NAME")
[[ -n "$WIDGET_BUNDLE_ID" ]] && CMD+=(--widget-bundle-id "$WIDGET_BUNDLE_ID")
[[ -n "$APP_GROUP" ]] && CMD+=(--app-group "$APP_GROUP")
[[ -n "$URL_SCHEME" ]] && CMD+=(--url-scheme "$URL_SCHEME")
[[ -n "$ACCENT_HEX" ]] && CMD+=(--accent "$ACCENT_HEX")
[[ -n "$ADMOB_APP_ID" ]] && CMD+=(--admob-app-id "$ADMOB_APP_ID")

"${CMD[@]}"

echo "YCAppStarter V3.1 setup completed. Run: xcodegen generate"
