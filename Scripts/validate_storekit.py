#!/usr/bin/env python3
from __future__ import annotations
import json, sys
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
path = ROOT / "StoreKit/YCAppStarter.storekit"
errors: list[str] = []
warnings: list[str] = []
if not path.exists():
    errors.append("Missing StoreKit/YCAppStarter.storekit")
else:
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
        products = data.get("products", [])
        if not products:
            warnings.append("StoreKit file has no products")
        ids = [p.get("productID") for p in products if p.get("productID")]
        if len(ids) != len(set(ids)):
            errors.append("Duplicate StoreKit product IDs")
        if "premium_lifetime" not in ids:
            warnings.append("premium_lifetime sample product is missing")
    except Exception as exc:
        errors.append(f"Invalid StoreKit JSON: {exc}")
print("validate_storekit")
print("=" * 17)
for e in errors: print(f"❌ {e}")
for w in warnings: print(f"⚠️ {w}")
print(f"Summary: {len(errors)} error(s), {len(warnings)} warning(s)")
sys.exit(1 if errors else 0)
