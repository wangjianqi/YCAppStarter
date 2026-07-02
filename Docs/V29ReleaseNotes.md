# YCAppStarter V2.9 Release Notes

V2.9 adds the Widget + Live Activity + Dynamic Island Kit.

## Added

- WidgetKit extension target.
- Shared App Group UserDefaults snapshot store.
- ActivityKit attributes shared by the app and widget extension.
- Live Activity debug controls.
- Dynamic Island debug/readiness page.
- Widget Debug page.
- App Group configuration script.
- Widget validation script.
- Doctor V2.9 checks.

## Default Policy

The widget is enabled by default because it is a low-risk local surface. Live Activity and Dynamic Island remote flags are disabled by default until each app chooses a real use case.

## Production Notes

Before App Store submission, configure a real App Group in Apple Developer portal, enable it for both the app target and widget extension target, and run:

```bash
python3 Scripts/configure_app_group.py --app-group group.com.yourcompany.yourapp
```
