# FirebasePlugin

`FirebasePlugin` is the V2.2 production analytics and crash reporting adapter. It overrides `NoopAnalyticsTracker` and `NoopCrashReporter` only when `GoogleService-Info.plist` is bundled.

## Files

```text
Sources/YCAppStarter/Plugins/Firebase/
├── FirebasePlugin.swift
├── FirebaseAnalyticsTracker.swift
└── FirebaseCrashReporter.swift
```

## Setup

1. Create or open your Firebase project.
2. Register an iOS app using the exact Bundle ID.
3. Download `GoogleService-Info.plist`.
4. Place it under:

```text
Sources/YCAppStarter/Resources/GoogleService-Info.plist
```

5. Run:

```bash
python3 Scripts/ycstarter_doctor.py
xcodegen generate
```

## App-facing API

```swift
container.service(AnalyticsTracking.self)?.track(AnalyticsEvent("event_name"))
container.service(CrashReporting.self)?.record(error: error)
```

Do not call Firebase directly from feature modules.

## Debugging

Open:

```text
Settings > Analytics Debug
```

Use:

- Send Test Analytics Event
- Record Non-Fatal Test Error

Firebase events may not appear instantly. Use Firebase DebugView when validating event flow.
