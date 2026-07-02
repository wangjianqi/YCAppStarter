#!/usr/bin/env python3
"""Validate YCAppStarter RemoteConfigDefaults.json.

This script checks the local fallback file before xcodegen/build so remote operations
have safe defaults even when Firebase Remote Config is unavailable.
"""
import argparse
import json
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_PATH = ROOT / "Sources/YCAppStarter/Resources/RemoteConfigDefaults.json"

REQUIRED_KEYS: dict[str, type | tuple[type, ...]] = {
    "review_safe_mode_enabled": bool,
    "feature_kill_switch_enabled": bool,
    "paywall_enabled": bool,
    "paywall_variant": str,
    "ads_enabled": bool,
    "admob_banner_enabled": bool,
    "admob_interstitial_enabled": bool,
    "admob_rewarded_enabled": bool,
    "promotion_banner_enabled": bool,
    "promotion_title": str,
    "promotion_message": str,
    "minimum_supported_build": int,
    "maintenance_message": str,
    "ai_enabled": bool,
    "ai_streaming_enabled": bool,
    "ai_vision_enabled": bool,
    "ai_default_model": str,
    "ai_daily_quota": int,
    "auth_enabled": bool,
    "auth_require_login_for_ai": bool,
    "auth_allow_email_password": bool,
    "auth_allow_apple": bool,
    "profile_sync_enabled": bool,
    "membership_sync_enabled": bool,
    "ai_usage_sync_enabled": bool,
}

VALID_PAYWALL_VARIANTS = {"minimal", "visualHero", "comparison"}


def main() -> int:
    parser = argparse.ArgumentParser(description="Validate RemoteConfigDefaults.json.")
    parser.add_argument("--path", default=str(DEFAULT_PATH), help="Path to RemoteConfigDefaults.json.")
    parser.add_argument("--strict", action="store_true", help="Return non-zero for warnings.")
    args = parser.parse_args()

    path = Path(args.path)
    errors: list[str] = []
    warnings: list[str] = []

    if not path.exists():
        errors.append(f"Remote config file does not exist: {path}")
    else:
        try:
            data: dict[str, Any] = json.loads(path.read_text(encoding="utf-8"))
        except Exception as exc:  # noqa: BLE001
            errors.append(f"Invalid JSON: {exc}")
            data = {}

        for key, expected_type in REQUIRED_KEYS.items():
            if key not in data:
                errors.append(f"Missing required key: {key}")
                continue
            if not isinstance(data[key], expected_type):
                errors.append(f"Invalid type for {key}: expected {expected_type}, got {type(data[key]).__name__}")

        variant = data.get("paywall_variant")
        if isinstance(variant, str) and variant not in VALID_PAYWALL_VARIANTS:
            warnings.append(f"paywall_variant '{variant}' is not one of: {', '.join(sorted(VALID_PAYWALL_VARIANTS))}")

        if data.get("review_safe_mode_enabled") is True and data.get("ads_enabled") is True:
            warnings.append("review_safe_mode_enabled=true but ads_enabled=true. Effective runtime policy will suppress ads, but defaults are contradictory.")

        for placement_key in ["admob_banner_enabled", "admob_interstitial_enabled", "admob_rewarded_enabled"]:
            if data.get(placement_key) is True and data.get("ads_enabled") is False:
                warnings.append(f"{placement_key}=true but ads_enabled=false. Global policy will suppress this placement.")

        if data.get("ai_streaming_enabled") is True and data.get("ai_enabled") is False:
            warnings.append("ai_streaming_enabled=true but ai_enabled=false. Global AI policy will suppress streaming.")

        if data.get("ai_vision_enabled") is True and data.get("ai_enabled") is False:
            warnings.append("ai_vision_enabled=true but ai_enabled=false. Global AI policy will suppress vision.")

        if data.get("auth_require_login_for_ai") is True and data.get("auth_enabled") is False:
            warnings.append("auth_require_login_for_ai=true but auth_enabled=false. AI auth policy will not be satisfiable.")

        if data.get("profile_sync_enabled") is True and data.get("auth_enabled") is False:
            warnings.append("profile_sync_enabled=true but auth_enabled=false. Profile sync requires authentication.")

        if data.get("feature_kill_switch_enabled") is True:
            warnings.append("feature_kill_switch_enabled=true in bundled defaults. This should normally be false for production builds.")

    for message in errors:
        print(f"[ERR] {message}")
    for message in warnings:
        print(f"[WARN] {message}")

    print(f"Summary: {len(errors)} error(s), {len(warnings)} warning(s)")
    if errors or (args.strict and warnings):
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
