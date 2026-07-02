#!/usr/bin/env python3
"""Validate the V2.8 Cloudflare Workers/Hono AI backend template."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BACKEND = ROOT / "Backend/ai-proxy"

REQUIRED = [
    "package.json",
    "wrangler.jsonc",
    "tsconfig.json",
    ".dev.vars.example",
    "src/index.ts",
    "src/openai.ts",
    "src/quota.ts",
    "src/auth.ts",
    "src/types.ts",
]

def main() -> int:
    errors: list[str] = []
    warnings: list[str] = []

    for rel in REQUIRED:
        if not (BACKEND / rel).exists():
            errors.append(f"Missing Backend/ai-proxy/{rel}")

    package_path = BACKEND / "package.json"
    if package_path.exists():
        try:
            data = json.loads(package_path.read_text(encoding="utf-8"))
            deps = {**data.get("dependencies", {}), **data.get("devDependencies", {})}
            for name in ["hono", "jose", "wrangler", "typescript"]:
                if name not in deps:
                    errors.append(f"package.json missing dependency: {name}")
        except Exception as exc:  # noqa: BLE001
            errors.append(f"package.json is invalid JSON: {exc}")

    env_example = BACKEND / ".dev.vars.example"
    if env_example.exists():
        text = env_example.read_text(encoding="utf-8")
        for key in ["OPENAI_API_KEY", "AI_PROXY_CLIENT_TOKEN", "AI_DEFAULT_MODEL", "SUPABASE_URL", "SUPABASE_REQUIRE_AUTH"]:
            if key not in text:
                warnings.append(f".dev.vars.example missing {key}")

    for message in errors:
        print(f"[ERR] {message}")
    for message in warnings:
        print(f"[WARN] {message}")
    print(f"Summary: {len(errors)} error(s), {len(warnings)} warning(s)")
    return 1 if errors else 0

if __name__ == "__main__":
    raise SystemExit(main())
