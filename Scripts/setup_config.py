#!/usr/bin/env python3
import argparse
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

def replace(path: Path, old: str, new: str):
    text = path.read_text(encoding="utf-8")
    text = text.replace(old, new)
    path.write_text(text, encoding="utf-8")

def hex_to_components(value: str):
    value = value.strip().lstrip('#')
    if len(value) != 6 or not re.match(r"^[0-9a-fA-F]{6}$", value):
        raise SystemExit("Accent must be a 6-digit hex, for example #B8FF2C")
    r = int(value[0:2], 16) / 255
    g = int(value[2:4], 16) / 255
    b = int(value[4:6], 16) / 255
    return f"{r:.2f}", f"{g:.2f}", f"{b:.2f}"

parser = argparse.ArgumentParser()
parser.add_argument('--app-name')
parser.add_argument('--bundle-id')
parser.add_argument('--accent')
args = parser.parse_args()

if args.app_name:
    replace(ROOT/'project.yml', 'PRODUCT_NAME: YCAppStarter', f'PRODUCT_NAME: {args.app_name}')
    replace(ROOT/'Sources/YCAppStarter/Info.plist', '<string>YCAppStarter</string>', f'<string>{args.app_name}</string>')
    replace(ROOT/'Sources/YCAppStarter/Config/AppConfig.swift', 'displayName: "YCAppStarter"', f'displayName: "{args.app_name}"')

if args.bundle_id:
    replace(ROOT/'project.yml', 'PRODUCT_BUNDLE_IDENTIFIER: com.yuechuanlabs.ycappstarter', f'PRODUCT_BUNDLE_IDENTIFIER: {args.bundle_id}')
    replace(ROOT/'Sources/YCAppStarter/Config/AppConfig.swift', 'bundleIdentifier: "com.yuechuanlabs.ycappstarter"', f'bundleIdentifier: "{args.bundle_id}"')

if args.accent:
    r, g, b = hex_to_components(args.accent)
    accent_path = ROOT/'Sources/YCAppStarter/Resources/Assets.xcassets/AccentColor.colorset/Contents.json'
    data = json.loads(accent_path.read_text(encoding='utf-8'))
    comps = data['colors'][0]['color']['components']
    comps['red'] = r
    comps['green'] = g
    comps['blue'] = b
    comps['alpha'] = '1.00'
    accent_path.write_text(json.dumps(data, indent=2), encoding='utf-8')
