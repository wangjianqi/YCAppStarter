#!/usr/bin/env python3
"""Static validation for Supabase Auth/Profile kit files."""
import argparse
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REQUIRED_SQL_SNIPPETS = [
    "create table if not exists public.profiles",
    "alter table public.profiles enable row level security",
    "auth.uid()) = id",
    "create table if not exists public.ai_usage_events",
]

def main() -> int:
    parser = argparse.ArgumentParser(description="Validate Supabase schema template and starter config.")
    parser.add_argument("--strict", action="store_true")
    args = parser.parse_args()
    errors: list[str] = []
    warnings: list[str] = []

    sql = ROOT / "Supabase/migrations/0001_profiles_membership_ai_usage.sql"
    if not sql.exists():
        errors.append(f"Missing {sql.relative_to(ROOT)}")
    else:
        content = sql.read_text(encoding="utf-8").lower()
        for snippet in REQUIRED_SQL_SNIPPETS:
            if snippet not in content:
                errors.append(f"SQL template missing snippet: {snippet}")

    project = (ROOT / "project.yml").read_text(encoding="utf-8")
    if "supabase-swift" not in project or "product: Supabase" not in project:
        errors.append("project.yml does not include supabase-swift / Supabase product")

    secrets = (ROOT / "Sources/YCAppStarter/Config/AppSecrets.swift").read_text(encoding="utf-8")
    if 'supabaseURL: ""' in secrets:
        warnings.append("Supabase URL is empty")
    if 'supabaseAnonKey: ""' in secrets:
        warnings.append("Supabase anon/publishable key is empty")

    catalog = (ROOT / "Sources/YCAppStarter/Plugins/PluginCatalog.swift").read_text(encoding="utf-8")
    if "SupabaseAuthPlugin" not in catalog:
        errors.append("SupabaseAuthPlugin is not registered")

    for item in errors:
        print(f"[ERR] {item}")
    for item in warnings:
        print(f"[WARN] {item}")
    print(f"validate_supabase_schema: {len(errors)} error(s), {len(warnings)} warning(s)")
    if errors or (args.strict and warnings):
        return 1
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
