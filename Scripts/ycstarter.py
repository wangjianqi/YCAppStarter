#!/usr/bin/env python3
from __future__ import annotations
import argparse, subprocess, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

def run(cmd: list[str]) -> int:
    print("$", " ".join(cmd))
    return subprocess.call(cmd, cwd=ROOT)

parser = argparse.ArgumentParser(prog="ycstarter", description="Unified YCAppStarter CLI.")
sub = parser.add_subparsers(dest="command", required=True)

doctor = sub.add_parser("doctor")
doctor.add_argument("--strict", action="store_true")

validate = sub.add_parser("validate")
validate.add_argument("--strict", action="store_true")

preflight = sub.add_parser("preflight")
preflight.add_argument("--strict", action="store_true")
preflight.add_argument("--ci", action="store_true")

storekit = sub.add_parser("storekit")
storekit.add_argument("--strict", action="store_true")

ci = sub.add_parser("ci")
ci.add_argument("--strict", action="store_true")

init = sub.add_parser("init")
init.add_argument("--app-name")
init.add_argument("--bundle-id", required=True)
init.add_argument("--widget-bundle-id")
init.add_argument("--app-group")
init.add_argument("--url-scheme")
init.add_argument("--accent")
init.add_argument("--admob-app-id")

plugin = sub.add_parser("new-plugin")
plugin.add_argument("name")
plugin.add_argument("--feature", required=True)
plugin.add_argument("--category", default="growth")
args = parser.parse_args()

def strict_arg(enabled: bool) -> list[str]:
    return ["--strict"] if enabled else []

if args.command == "doctor":
    sys.exit(run(["python3", "Scripts/ycstarter_doctor.py", *strict_arg(args.strict)]))
if args.command == "storekit":
    sys.exit(run(["python3", "Scripts/validate_storekit.py", *strict_arg(args.strict)]))
if args.command == "ci":
    sys.exit(run(["python3", "Scripts/validate_ci.py", *strict_arg(args.strict)]))
if args.command == "preflight":
    sys.exit(run(["python3", "Scripts/appstore_preflight.py", *( ["--ci"] if args.ci else [] ), *strict_arg(args.strict)]))
if args.command == "init":
    cmd = ["python3", "Scripts/setup_config.py", "init", "--bundle-id", args.bundle_id]
    for key in ["app_name", "widget_bundle_id", "app_group", "url_scheme", "accent", "admob_app_id"]:
        value = getattr(args, key)
        if value:
            cmd.extend(["--" + key.replace("_", "-"), value])
    sys.exit(run(cmd))
if args.command == "new-plugin":
    sys.exit(run(["python3", "Scripts/new_plugin.py", args.name, "--feature", args.feature, "--category", args.category]))
if args.command == "validate":
    commands = [
        ["python3", "Scripts/validate_remote_config.py", *strict_arg(args.strict)],
        ["python3", "Scripts/validate_deep_links.py"],
        ["python3", "Scripts/validate_ai_backend.py"],
        ["python3", "Scripts/validate_supabase_schema.py"],
        ["python3", "Scripts/validate_widgets.py", *strict_arg(args.strict)],
        ["python3", "Scripts/validate_storekit.py", *strict_arg(args.strict)],
        ["python3", "Scripts/validate_ci.py", *strict_arg(args.strict)],
        ["python3", "Scripts/check_localization.py"],
        ["python3", "Scripts/check_stale_version_refs.py"],
        ["python3", "Scripts/ycstarter_doctor.py", *strict_arg(args.strict)],
    ]
    failed = 0
    for cmd in commands:
        if run(cmd) != 0:
            failed += 1
    sys.exit(1 if failed else 0)
