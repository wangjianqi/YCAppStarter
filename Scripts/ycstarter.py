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
sub.add_parser("doctor")
sub.add_parser("validate")
sub.add_parser("preflight")
sub.add_parser("storekit")
sub.add_parser("ci")
plugin = sub.add_parser("new-plugin")
plugin.add_argument("name")
plugin.add_argument("--feature", required=True)
plugin.add_argument("--category", default="growth")
args = parser.parse_args()

if args.command == "doctor":
    sys.exit(run(["python3", "Scripts/ycstarter_doctor.py"]))
if args.command == "storekit":
    sys.exit(run(["python3", "Scripts/validate_storekit.py"]))
if args.command == "ci":
    sys.exit(run(["python3", "Scripts/validate_ci.py"]))
if args.command == "preflight":
    sys.exit(run(["python3", "Scripts/appstore_preflight.py"]))
if args.command == "new-plugin":
    sys.exit(run(["python3", "Scripts/new_plugin.py", args.name, "--feature", args.feature, "--category", args.category]))
if args.command == "validate":
    commands = [
        ["python3", "Scripts/validate_remote_config.py"],
        ["python3", "Scripts/validate_deep_links.py"],
        ["python3", "Scripts/validate_ai_backend.py"],
        ["python3", "Scripts/validate_supabase_schema.py"],
        ["python3", "Scripts/validate_widgets.py"],
        ["python3", "Scripts/validate_storekit.py"],
        ["python3", "Scripts/validate_ci.py"],
        ["python3", "Scripts/check_localization.py"],
        ["python3", "Scripts/ycstarter_doctor.py"],
    ]
    failed = 0
    for cmd in commands:
        if run(cmd) != 0:
            failed += 1
    sys.exit(1 if failed else 0)
