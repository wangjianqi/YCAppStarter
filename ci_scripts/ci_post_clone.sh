#!/bin/zsh
set -euo pipefail

echo "[YCAppStarter] post-clone checks"
if command -v brew >/dev/null 2>&1 && ! command -v xcodegen >/dev/null 2>&1; then
  brew install xcodegen
fi
python3 Scripts/ycstarter.py validate
xcodegen generate
