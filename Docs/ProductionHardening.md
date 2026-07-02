# Production Hardening Kit

V3.0 turns the starter from a feature-rich boilerplate into a release-oriented template.

## Gates

- Static doctor checks.
- App Store preflight checks.
- StoreKit test config validation.
- CI script validation.
- Plugin catalog uniqueness checks.
- Remote Config key checks.

## Build environments

Use `Config/Environments/Development.xcconfig`, `Staging.xcconfig` and `Production.xcconfig` as the canonical environment split.

## Local command

```bash
python3 Scripts/ycstarter.py validate
```

## CI command

```bash
python3 Scripts/validate_production.py
```
