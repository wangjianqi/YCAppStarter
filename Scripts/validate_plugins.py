#!/usr/bin/env python3
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
catalog = ROOT/'Sources/YCAppStarter/Plugins/PluginCatalog.swift'
features = ROOT/'Sources/YCAppStarter/Config/FeatureFlags.swift'

catalog_text = catalog.read_text(encoding='utf-8')
feature_text = features.read_text(encoding='utf-8')
registered = re.findall(r'AnyAppPlugin\((\w+Plugin)\(\)\)', catalog_text)
feature_cases = set(re.findall(r'case (\w+)', feature_text))

print('Registered plugins:')
for item in registered:
    print(f'  - {item}')

print(f'Feature cases: {len(feature_cases)}')
print('Validation completed. This script is intentionally lightweight; Xcode remains the source of truth.')
