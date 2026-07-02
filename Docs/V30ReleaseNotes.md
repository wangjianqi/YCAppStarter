# YCAppStarter V3.0 Release Notes

V3.0 is the Production Hardening Kit release. It focuses on making the starter safer to reuse, test, validate and package.

## Added

- Multi-environment xcconfig files.
- Production readiness plugin and in-app release gate page.
- StoreKit test configuration and validation script.
- Xcode Cloud-compatible `ci_scripts` hooks.
- Optional GitHub Actions validation workflow.
- Unified `ycstarter.py` CLI.
- App Store preflight script.
- Analytics event catalog and tests.
- Unit test target skeleton.
- Commercial delivery and license templates.

## Recommended validation

```bash
python3 Scripts/ycstarter.py validate
xcodegen generate
```
