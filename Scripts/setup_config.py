#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import plistlib
import re
from pathlib import Path
from xml.sax.saxutils import escape

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_BUNDLE_ID = "com.yuechuanlabs.ycappstarter"
DEFAULT_WIDGET_BUNDLE_ID = "com.yuechuanlabs.ycappstarter.widgets"
DEFAULT_TEST_BUNDLE_ID = "com.yuechuanlabs.ycappstarter.tests"
DEFAULT_APP_GROUP = "group.com.yuechuanlabs.ycappstarter"
DEFAULT_URL_SCHEME = "ycappstarter"
DEFAULT_APP_NAME = "YCAppStarter"


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def write(path: str, value: str) -> None:
    (ROOT / path).write_text(value, encoding="utf-8")


def replace_text(path: str, old: str, new: str) -> None:
    p = ROOT / path
    if not p.exists():
        return
    text = p.read_text(encoding="utf-8")
    text = text.replace(old, new)
    p.write_text(text, encoding="utf-8")


def set_project_value(text: str, key: str, value: str, occurrence: int = 1) -> str:
    pattern = re.compile(rf"(^\s*{re.escape(key)}:\s*)(.+)$", re.MULTILINE)
    count = 0
    def repl(match: re.Match[str]) -> str:
        nonlocal count
        count += 1
        if count == occurrence:
            return f"{match.group(1)}{value}"
        return match.group(0)
    return pattern.sub(repl, text)


def bundle_id_to_scheme(bundle_id: str) -> str:
    return re.sub(r"[^a-z0-9]+", "", bundle_id.lower().split(".")[-1]) or "app"


def plist_update(path: str, updates: dict) -> None:
    p = ROOT / path
    data = plistlib.loads(p.read_bytes())
    data.update(updates)
    p.write_bytes(plistlib.dumps(data, sort_keys=False))


def update_url_scheme(path: str, scheme: str, app_name: str | None = None) -> None:
    p = ROOT / path
    data = plistlib.loads(p.read_bytes())
    url_types = data.setdefault("CFBundleURLTypes", [{}])
    if not url_types:
        url_types.append({})
    url_types[0]["CFBundleTypeRole"] = url_types[0].get("CFBundleTypeRole", "Editor")
    if app_name:
        url_types[0]["CFBundleURLName"] = f"{app_name} Auth"
    url_types[0]["CFBundleURLSchemes"] = [scheme]
    p.write_bytes(plistlib.dumps(data, sort_keys=False))


def update_entitlements(path: str, app_group: str | None, apns_environment: str | None = None) -> None:
    p = ROOT / path
    data = plistlib.loads(p.read_bytes())
    if app_group:
        data["com.apple.security.application-groups"] = [app_group]
    if apns_environment and "aps-environment" in data:
        data["aps-environment"] = apns_environment
    p.write_bytes(plistlib.dumps(data, sort_keys=False))


def update_xcconfig(key: str, value: str) -> None:
    for rel in [
        "Config/Environments/Base.xcconfig",
        "Config/Environments/Development.xcconfig",
        "Config/Environments/Staging.xcconfig",
        "Config/Environments/Production.xcconfig",
    ]:
        p = ROOT / rel
        if not p.exists():
            continue
        text = p.read_text(encoding="utf-8")
        if re.search(rf"^{re.escape(key)}\s*=", text, flags=re.MULTILINE):
            text = re.sub(rf"^{re.escape(key)}\s*=.*$", f"{key} = {value}", text, flags=re.MULTILINE)
        elif rel.endswith("Base.xcconfig"):
            text = text.rstrip() + f"\n{key} = {value}\n"
        p.write_text(text, encoding="utf-8")


def hex_to_components(value: str):
    value = value.strip().lstrip("#")
    if len(value) != 6 or not re.match(r"^[0-9a-fA-F]{6}$", value):
        raise SystemExit("Accent must be a 6-digit hex, for example #B8FF2C")
    r = int(value[0:2], 16) / 255
    g = int(value[2:4], 16) / 255
    b = int(value[4:6], 16) / 255
    return f"{r:.2f}", f"{g:.2f}", f"{b:.2f}"


def configure_app_name(app_name: str) -> None:
    escaped = escape(app_name)
    project = read("project.yml")
    project = re.sub(r"PRODUCT_NAME:\s*.*", f"PRODUCT_NAME: {app_name}", project, count=1)
    write("project.yml", project)
    replace_text("Sources/YCAppStarter/Config/AppConfig.swift", f'displayName: "{DEFAULT_APP_NAME}"', f'displayName: "{app_name}"')
    plist_update("Sources/YCAppStarter/Info.plist", {"CFBundleDisplayName": app_name, "CFBundleName": app_name})
    update_url_scheme("Sources/YCAppStarter/Info.plist", current_url_scheme(), app_name=app_name)
    for rel in ["README.md", "Metadata/app_name.md"]:
        p = ROOT / rel
        if p.exists():
            replace_text(rel, DEFAULT_APP_NAME, app_name)


def current_url_scheme() -> str:
    data = plistlib.loads((ROOT / "Sources/YCAppStarter/Info.plist").read_bytes())
    try:
        scheme = data["CFBundleURLTypes"][0]["CFBundleURLSchemes"][0]
        if scheme and not scheme.startswith("$("):
            return scheme
    except Exception:
        pass
    return DEFAULT_URL_SCHEME


def configure_bundle_id(bundle_id: str, widget_bundle_id: str | None = None, test_bundle_id: str | None = None) -> None:
    widget_bundle_id = widget_bundle_id or f"{bundle_id}.widgets"
    test_bundle_id = test_bundle_id or f"{bundle_id}.tests"
    project = read("project.yml")
    # Replace longer default identifiers first so a custom widget/test bundle ID is not swallowed by the app bundle replacement.
    project = project.replace(DEFAULT_WIDGET_BUNDLE_ID, widget_bundle_id)
    project = project.replace(DEFAULT_TEST_BUNDLE_ID, test_bundle_id)
    project = project.replace(DEFAULT_BUNDLE_ID, bundle_id)
    write("project.yml", project)
    replace_text("Sources/YCAppStarter/Config/AppConfig.swift", f'bundleIdentifier: "{DEFAULT_BUNDLE_ID}"', f'bundleIdentifier: "{bundle_id}"')
    replace_text("Sources/YCAppStarter/Config/AppSecrets.swift", 'pushTopicBundleID: ""', f'pushTopicBundleID: "{bundle_id}"')


def configure_app_group(app_group: str) -> None:
    update_xcconfig("YC_STARTER_APP_GROUP_IDENTIFIER", app_group)
    replace_text("Sources/YCAppStarter/Config/AppSecrets.swift", DEFAULT_APP_GROUP, app_group)
    update_entitlements("Sources/YCAppStarter/YCAppStarter.entitlements", app_group)
    update_entitlements("Sources/YCAppStarterWidgets/YCAppStarterWidgets.entitlements", app_group)
    plist_update("Sources/YCAppStarter/Info.plist", {"YC_STARTER_APP_GROUP_IDENTIFIER": app_group})
    plist_update("Sources/YCAppStarterWidgets/Info.plist", {"YC_STARTER_APP_GROUP_IDENTIFIER": app_group})


def configure_url_scheme(url_scheme: str) -> None:
    update_xcconfig("YC_STARTER_URL_SCHEME", url_scheme)
    replace_text("Sources/YCAppStarter/Config/AppSecrets.swift", f'supabaseRedirectScheme: "{DEFAULT_URL_SCHEME}"', f'supabaseRedirectScheme: "{url_scheme}"')
    update_url_scheme("Sources/YCAppStarter/Info.plist", url_scheme)
    plist_update("Sources/YCAppStarter/Info.plist", {"YC_STARTER_URL_SCHEME": url_scheme})
    plist_update("Sources/YCAppStarterWidgets/Info.plist", {"YC_STARTER_URL_SCHEME": url_scheme})


def configure_accent(accent: str) -> None:
    r, g, b = hex_to_components(accent)
    accent_path = ROOT / "Sources/YCAppStarter/Resources/Assets.xcassets/AccentColor.colorset/Contents.json"
    data = json.loads(accent_path.read_text(encoding="utf-8"))
    comps = data["colors"][0]["color"]["components"]
    comps["red"] = r
    comps["green"] = g
    comps["blue"] = b
    comps["alpha"] = "1.00"
    accent_path.write_text(json.dumps(data, indent=2), encoding="utf-8")


def configure_admob_app_id(admob_app_id: str) -> None:
    update_xcconfig("YC_STARTER_ADMOB_APP_ID", admob_app_id)
    plist_update("Sources/YCAppStarter/Info.plist", {"GADApplicationIdentifier": admob_app_id})
    replace_text("Sources/YCAppStarter/Config/AppSecrets.swift", "ca-app-pub-3940256099942544~1458002511", admob_app_id)


def init_project(args: argparse.Namespace) -> None:
    bundle_id = args.bundle_id
    widget_bundle_id = args.widget_bundle_id or f"{bundle_id}.widgets"
    app_group = args.app_group or f"group.{bundle_id}"
    url_scheme = args.url_scheme or bundle_id_to_scheme(bundle_id)

    if args.app_name:
        configure_app_name(args.app_name)
    configure_bundle_id(bundle_id, widget_bundle_id=widget_bundle_id)
    configure_app_group(app_group)
    configure_url_scheme(url_scheme)
    if args.accent:
        configure_accent(args.accent)
    if args.admob_app_id:
        configure_admob_app_id(args.admob_app_id)

    print("YCAppStarter V3.1 init completed")
    print(f"App name: {args.app_name or DEFAULT_APP_NAME}")
    print(f"Bundle ID: {bundle_id}")
    print(f"Widget Bundle ID: {widget_bundle_id}")
    print(f"App Group: {app_group}")
    print(f"URL Scheme: {url_scheme}")


def main() -> int:
    parser = argparse.ArgumentParser(description="Configure YCAppStarter template values.")
    sub = parser.add_subparsers(dest="command")

    init = sub.add_parser("init", help="Configure all product identity values in one pass.")
    init.add_argument("--app-name")
    init.add_argument("--bundle-id", required=True)
    init.add_argument("--widget-bundle-id")
    init.add_argument("--app-group")
    init.add_argument("--url-scheme")
    init.add_argument("--accent")
    init.add_argument("--admob-app-id")

    parser.add_argument("--app-name")
    parser.add_argument("--bundle-id")
    parser.add_argument("--widget-bundle-id")
    parser.add_argument("--app-group")
    parser.add_argument("--url-scheme")
    parser.add_argument("--accent")
    parser.add_argument("--admob-app-id")

    args = parser.parse_args()
    if args.command == "init":
        init_project(args)
        return 0

    if args.app_name:
        configure_app_name(args.app_name)
    if args.bundle_id:
        configure_bundle_id(args.bundle_id, widget_bundle_id=args.widget_bundle_id)
    if args.app_group:
        configure_app_group(args.app_group)
    if args.url_scheme:
        configure_url_scheme(args.url_scheme)
    if args.accent:
        configure_accent(args.accent)
    if args.admob_app_id:
        configure_admob_app_id(args.admob_app_id)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
