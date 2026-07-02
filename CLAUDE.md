# YCAppStarter V3.0 Agent Notes

This is a plugin-first SwiftUI starter. Preserve the plugin boundary.

## Rules

- Do not import third-party SDKs directly from business views.
- Use protocol services from `Core/*` and register concrete adapters through plugins.
- New features should add an `AppFeature`, plugin descriptor, health checks, route and docs.
- Run `python3 Scripts/ycstarter.py validate` after changes.
- Production work should pass `Scripts/appstore_preflight.py`, `Scripts/validate_storekit.py` and `Scripts/validate_ci.py`.
