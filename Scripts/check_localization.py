#!/usr/bin/env python3
"""Static localization audit for YCAppStarter string catalogs.

Usage:
  python3 Scripts/check_localization.py
  python3 Scripts/check_localization.py --strict
"""
import argparse
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CATALOG = ROOT / "Sources/YCAppStarter/Resources/Localizable.xcstrings"


def main() -> int:
    parser = argparse.ArgumentParser(description="Audit Localizable.xcstrings for missing and empty translations.")
    parser.add_argument("--strict", action="store_true", help="Return non-zero when warnings are found.")
    args = parser.parse_args()

    warnings: list[str] = []
    errors: list[str] = []

    if not CATALOG.exists():
        errors.append(f"Missing string catalog: {CATALOG.relative_to(ROOT)}")
    else:
        try:
            data = json.loads(CATALOG.read_text(encoding="utf-8"))
        except Exception as exc:  # noqa: BLE001
            errors.append(f"Invalid JSON in Localizable.xcstrings: {exc}")
            data = {}

        strings = data.get("strings", {}) if isinstance(data, dict) else {}
        source_language = data.get("sourceLanguage", "unknown") if isinstance(data, dict) else "unknown"
        if not strings:
            warnings.append("No localized strings were found. Move user-facing text into Localizable.xcstrings before release.")
        else:
            languages: set[str] = set()
            for entry in strings.values():
                for language in entry.get("localizations", {}).keys():
                    languages.add(language)
            if not languages:
                warnings.append(f"No target localizations were found. Source language: {source_language}.")
            for key, entry in strings.items():
                localizations = entry.get("localizations", {})
                for language, localization in localizations.items():
                    value = localization.get("stringUnit", {}).get("value", "")
                    state = localization.get("stringUnit", {}).get("state", "")
                    if not value.strip():
                        warnings.append(f"Empty localization: key={key!r}, language={language}")
                    if state and state not in {"translated", "new", "needs_review"}:
                        warnings.append(f"Unexpected localization state: key={key!r}, language={language}, state={state!r}")

    print("YCAppStarter Localization Audit")
    print("=" * 34)
    if errors:
        for error in errors:
            print(f"[ERR] {error}")
    if warnings:
        for warning in warnings:
            print(f"[WARN] {warning}")
    if not errors and not warnings:
        print("[OK] No localization issues found")
    print("-" * 34)
    print(f"Summary: {len(errors)} error(s), {len(warnings)} warning(s)")

    if errors or (args.strict and warnings):
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
