#!/bin/zsh
set -euo pipefail

echo "[YCAppStarter] pre-xcodebuild production gate"
python3 Scripts/validate_ci.py
python3 Scripts/appstore_preflight.py --ci
