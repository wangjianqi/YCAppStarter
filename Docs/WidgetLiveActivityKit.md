# Widget + Live Activity + Dynamic Island Kit

V2.9 adds a starter implementation for WidgetKit, ActivityKit and Dynamic Island surfaces.

## Architecture

```text
Main App
  ↓ WidgetManaging
AppGroupWidgetStore
  ↓ UserDefaults(suiteName: group.*)
Widget Extension
  ↓ TimelineProvider
Home Screen / Lock Screen Widget
```

Live Activities use shared attributes under `Sources/Shared/LiveActivities` so the app target can start/update/end activities and the widget extension can render them.

## Files

```text
Sources/Shared/Widgets/WidgetSharedModels.swift
Sources/Shared/LiveActivities/StarterLiveActivityAttributes.swift
Sources/YCAppStarter/Core/Widgets
Sources/YCAppStarter/Core/LiveActivities
Sources/YCAppStarterWidgets
```

## Remote Config

```json
{
  "widget_enabled": true,
  "widget_refresh_minutes": 60,
  "live_activity_enabled": false,
  "dynamic_island_enabled": false,
  "live_activity_push_updates_enabled": false
}
```

## App Group

The app and widget extension must share the same App Group. Configure it with:

```bash
python3 Scripts/configure_app_group.py --app-group group.com.yourcompany.yourapp
```

## Live Activity Push Updates

V2.9 includes client-side start/update/end controls and a push-token start option. A production app still needs server-side APNs Live Activity push handling before remote updates are complete.
