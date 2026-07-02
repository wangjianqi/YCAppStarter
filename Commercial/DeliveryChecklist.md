# YCAppStarter Commercial Delivery Checklist

Use this checklist before shipping the starter to a client or packaging it as a paid product.

## Required

- Replace sample Bundle ID and App Group identifiers.
- Run `python3 Scripts/ycstarter.py validate`.
- Run `xcodegen generate` on macOS.
- Open the generated project and run tests on at least one simulator.
- Confirm all SDK keys are removed from committed files.
- Confirm `Secrets.xcconfig` is ignored.
- Confirm the license file has the buyer name, purchase date and permitted seats.
- Confirm docs include setup, plugin deletion, troubleshooting and migration notes.

## Optional

- Record a setup video.
- Add a sample App Store Connect metadata package.
- Add a known issues file for the current release.
