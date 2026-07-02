# Manual Static Tests

Run these commands after editing plugins or remote config:

```bash
python3 Scripts/validate_remote_config.py
python3 Scripts/ycstarter_doctor.py
python3 Scripts/ycstarter_doctor.py --json
python3 Scripts/check_localization.py
python3 Scripts/new_plugin.py SampleCheck --feature sampleCheck
python3 Scripts/ycstarter_doctor.py
```

After generating a sample plugin, add `.sampleCheck` to `AppFeature`, rerun doctor, then remove the generated plugin if it was only a test.

Remote config must always keep a valid offline fallback:

```bash
python3 Scripts/validate_remote_config.py --strict
```
