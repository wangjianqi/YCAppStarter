#!/bin/zsh
set -euo pipefail

echo "[YCAppStarter] post-xcodebuild summary"
python3 Scripts/generate_release_notes.py --output build/release-notes.md || true
