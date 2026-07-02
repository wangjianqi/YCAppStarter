#!/usr/bin/env python3
import argparse
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

parser = argparse.ArgumentParser(description='Create a removable YCAppStarter plugin skeleton.')
parser.add_argument('name', help='Plugin name, for example AIChat or ExportTools')
parser.add_argument('--feature', help='AppFeature case, for example aiAssistant')
parser.add_argument('--category', default='sample', help='PluginCategory case')
parser.add_argument('--required-secret', action='append', default=[], help='SecretKey case, can be repeated, for example revenueCatAPIKey')
args = parser.parse_args()

name = ''.join(part[:1].upper() + part[1:] for part in args.name.replace('-', '_').split('_'))
if name.endswith('Plugin'):
    name = name[:-6]
feature = args.feature or name[:1].lower() + name[1:]
plugin_dir = ROOT / 'Sources' / 'YCAppStarter' / 'Plugins' / name
plugin_dir.mkdir(parents=True, exist_ok=True)
plugin_file = plugin_dir / f'{name}Plugin.swift'
plugin_id = 'yc.' + feature
required_secrets = '[' + ', '.join(f'.{item}' for item in args.required_secret) + ']'

plugin_file.write_text(f"""import Foundation

struct {name}Plugin: AppPlugin {{
    let descriptor = PluginDescriptor(
        id: "{plugin_id}",
        displayName: "{name}",
        version: .v24,
        feature: .{feature},
        category: .{args.category},
        requiredSecrets: {required_secrets},
        summary: "Describe what this plugin adds."
    )

    func registerServices(in registry: ServiceRegistry, secrets: AppSecrets, logger: AppLogging) {{
        // registry.register(YourServiceProtocol.self, service: YourService())
    }}

    func configure(container: AppContainer) async {{
        // Configure SDKs or warm up services here.
    }}

    func makeHomeItems(container: AppContainer) -> [PluginHomeItem] {{
        [
            PluginHomeItem(
                id: "{feature}-home",
                title: "{name}",
                subtitle: "Plugin home card",
                systemImage: "puzzlepiece.extension",
                route: .pluginDetail(descriptor.id)
            )
        ]
    }}

    func makeHealthChecks(container: AppContainer) -> [PluginHealthCheckResult] {{
        []
    }}
}}
""", encoding='utf-8')

catalog = ROOT/'Sources/YCAppStarter/Plugins/PluginCatalog.swift'
text = catalog.read_text(encoding='utf-8')
needle = 'AnyAppPlugin(DemoFeaturePlugin())'
replacement = f'AnyAppPlugin(DemoFeaturePlugin()),\n            AnyAppPlugin({name}Plugin())'
if f'{name}Plugin()' not in text:
    text = text.replace(needle, replacement)
    catalog.write_text(text, encoding='utf-8')

print(f'Created plugin: {plugin_file}')
print(f'Next: add case .{feature} to Config/FeatureFlags.swift and enable it in FeatureFlags.default if needed.')
print('Run: python3 Scripts/ycstarter_doctor.py')
