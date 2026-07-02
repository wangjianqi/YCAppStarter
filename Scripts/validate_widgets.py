#!/usr/bin/env python3
from __future__ import annotations
import plistlib, re, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
errors: list[str] = []
warnings: list[str] = []

def text(path: str) -> str:
    p = ROOT / path
    return p.read_text(encoding="utf-8") if p.exists() else ""

def require(path: str):
    if not (ROOT / path).exists():
        errors.append(f"Missing {path}")

for path in [
    "Sources/YCAppStarterWidgets/YCAppStarterWidgetsBundle.swift",
    "Sources/YCAppStarterWidgets/StarterStatusWidget.swift",
    "Sources/YCAppStarterWidgets/StarterLiveActivityWidget.swift",
    "Sources/Shared/LiveActivities/StarterLiveActivityAttributes.swift",
    "Sources/Shared/Widgets/WidgetSharedModels.swift",
    "Sources/YCAppStarter/Core/Widgets/WidgetManaging.swift",
    "Sources/YCAppStarter/Core/LiveActivities/LiveActivityManaging.swift",
]:
    require(path)

project = text("project.yml")
if "YCAppStarterWidgetsExtension" not in project:
    errors.append("project.yml is missing YCAppStarterWidgetsExtension target")
if "Sources/Shared" not in project:
    errors.append("project.yml should include Sources/Shared for app and widget targets")

try:
    app_ent = plistlib.loads((ROOT / "Sources/YCAppStarter/YCAppStarter.entitlements").read_bytes())
    widget_ent = plistlib.loads((ROOT / "Sources/YCAppStarterWidgets/YCAppStarterWidgets.entitlements").read_bytes())
    app_groups = set(app_ent.get("com.apple.security.application-groups", []))
    widget_groups = set(widget_ent.get("com.apple.security.application-groups", []))
    if not app_groups:
        errors.append("App entitlements missing App Group")
    if not widget_groups:
        errors.append("Widget entitlements missing App Group")
    if app_groups and widget_groups and app_groups != widget_groups:
        errors.append(f"App Group mismatch: app={app_groups}, widget={widget_groups}")
except Exception as exc:
    errors.append(f"Failed to parse entitlements: {exc}")

try:
    plist = plistlib.loads((ROOT / "Sources/YCAppStarter/Info.plist").read_bytes())
    if plist.get("NSSupportsLiveActivities") is not True:
        errors.append("Info.plist must set NSSupportsLiveActivities=true")
except Exception as exc:
    errors.append(f"Failed to parse app Info.plist: {exc}")

remote = text("Sources/YCAppStarter/Resources/RemoteConfigDefaults.json")
for key in ["widget_enabled", "widget_refresh_minutes", "live_activity_enabled", "dynamic_island_enabled", "live_activity_push_updates_enabled"]:
    if f'"{key}"' not in remote:
        errors.append(f"RemoteConfigDefaults.json missing {key}")

widget_source = text("Sources/YCAppStarterWidgets/StarterStatusWidget.swift")
match = re.search(r'UserDefaults\(suiteName: "([^"]+)"\)', widget_source)
if match and not match.group(1).startswith("group."):
    errors.append("Widget UserDefaults suiteName must be an App Group identifier")

print("validate_widgets")
print("=" * 16)
for item in errors:
    print(f"❌ {item}")
for item in warnings:
    print(f"⚠️ {item}")
print(f"Summary: {len(errors)} error(s), {len(warnings)} warning(s)")
sys.exit(1 if errors else 0)
