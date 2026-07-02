#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Checking YCAppStarter environment..."
command -v xcodegen >/dev/null 2>&1 || echo "Missing xcodegen. Install: brew install xcodegen"
command -v python3 >/dev/null 2>&1 || echo "Missing python3"
python3 "$ROOT/Scripts/ycstarter_doctor.py"
echo "Done."
