#!/usr/bin/env python3
from __future__ import annotations
import re, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PATTERNS = [r"YCAppStarter V2", r"V2 setup", r"YCAppStarter V3\.0", r"MARKETING_VERSION: 3\.0\.0", r"Current version: `3\.0\.0`"]
EXCLUDED_PARTS = {
    ".git", "__pycache__",
}
EXCLUDED_PREFIXES = (
    "Docs/Migration/",
    "Docs/V21", "Docs/V22", "Docs/V23", "Docs/V24", "Docs/V25", "Docs/V26", "Docs/V27", "Docs/V29", "Docs/V30",
    "Docs/V2.8",
)
EXCLUDED_FILES = {
    "Scripts/check_stale_version_refs.py",
    "Sources/YCAppStarter/Config/StarterVersion.swift",  # keeps historical constants intentionally
    "Sources/YCAppStarter/Config/FeatureFlags.swift",    # comments document feature lineage intentionally
    "Docs/Versioning.md",                                # contains versioning history intentionally
    "VERSIONING.md",
    "CHANGELOG.md",
}

findings: list[str] = []
for path in ROOT.rglob("*"):
    if not path.is_file():
        continue
    rel = path.relative_to(ROOT).as_posix()
    if any(part in EXCLUDED_PARTS for part in path.parts):
        continue
    if rel in EXCLUDED_FILES or rel.startswith(EXCLUDED_PREFIXES):
        continue
    if path.suffix not in {".swift", ".py", ".sh", ".md", ".yml", ".yaml", ".json", ".plist", ".xcconfig"} and path.name not in {"README.md", "AGENTS.md", "CLAUDE.md"}:
        continue
    try:
        text = path.read_text(encoding="utf-8")
    except UnicodeDecodeError:
        continue
    for i, line in enumerate(text.splitlines(), start=1):
        for pattern in PATTERNS:
            if re.search(pattern, line):
                findings.append(f"{rel}:{i}: {line.strip()}")

print("check_stale_version_refs")
print("=" * 24)
for item in findings:
    print(f"❌ {item}")
print(f"Summary: {len(findings)} stale reference(s)")
sys.exit(1 if findings else 0)
