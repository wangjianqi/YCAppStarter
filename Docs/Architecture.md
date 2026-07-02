# Architecture

YCAppStarter V2.4 uses a plugin-first architecture with three layers:

```text
App Shell
  ↓
Plugin Runtime + Service Registry
  ↓
Feature Plugins
```

## Core Rules

- `Core/` defines protocols, models and generic runtime services.
- `Plugins/` contains concrete implementations and SDK adapters.
- `Modules/` contains SwiftUI screens.
- Feature surfaces are contributed through plugin home/settings/debug items.
- Business screens should resolve services from `AppContainer` instead of directly importing SDKs.

## V2.4 Remote Operations

Remote operation controls are exposed by `RemoteConfigServicing` and interpreted by `LaunchPolicy`.

```text
RemoteConfigPlugin
├── LocalJSONRemoteConfigService
├── FirebaseRemoteConfigService
├── RemoteConfigView
└── ReviewSafeModeView
```

All remote controls must have bundled JSON fallback values.
