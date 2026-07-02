#!/usr/bin/env python3
from __future__ import annotations
import argparse, json, os, plistlib, re, shutil
from dataclasses import dataclass
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_BUNDLE_ID = "com.yuechuanlabs.ycappstarter"
DEFAULT_APP_GROUP = "group.com.yuechuanlabs.ycappstarter"
GOOGLE_SAMPLE_AD_PUBLISHER = "3940256099942544"

@dataclass
class Finding:
    level: str
    code: str
    message: str
    recovery: str = ""
    def render(self) -> str:
        icon = {"ok":"✅", "warning":"⚠️", "error":"❌"}.get(self.level, "•")
        return f"{icon} [{self.code}] {self.message}" + ("\n   Fix: " + self.recovery if self.level != "ok" and self.recovery else "")

def text(path: str) -> str:
    p = ROOT / path
    return p.read_text(encoding="utf-8") if p.exists() else ""

def exists(path: str, level="error") -> Finding:
    ok = (ROOT / path).exists()
    return Finding("ok" if ok else level, "file.exists" if ok else "file.missing", f"{path} {'exists' if ok else 'is missing'}", "Restore the file from the starter template." if not ok else "")

def plugin_catalog() -> list[str]:
    return re.findall(r"AnyAppPlugin\((\w+)\(\)\)", text("Sources/YCAppStarter/Plugins/PluginCatalog.swift"))

def plugin_files() -> list[str]:
    root = ROOT / "Sources/YCAppStarter/Plugins"
    return sorted(p.stem for p in root.glob("*/*Plugin.swift"))

def feature_cases() -> set[str]:
    return set(re.findall(r"case\s+(\w+)", text("Sources/YCAppStarter/Config/FeatureFlags.swift")))

def plist(path: str) -> dict:
    return plistlib.loads((ROOT / path).read_bytes())

def app_groups_from(path: str) -> set[str]:
    try:
        return set(plist(path).get("com.apple.security.application-groups", []))
    except Exception:
        return set()

def main() -> int:
    parser = argparse.ArgumentParser(description="Run static checks for YCAppStarter V3.1.")
    parser.add_argument("--json", action="store_true")
    parser.add_argument("--strict", action="store_true")
    args = parser.parse_args()
    findings: list[Finding] = []
    required = [
        "project.yml", ".starter-version", "Sources/YCAppStarter/Info.plist", "Sources/YCAppStarter/YCAppStarter.entitlements",
        "Sources/YCAppStarterWidgets/Info.plist", "Sources/YCAppStarterWidgets/YCAppStarterWidgets.entitlements", "Sources/Shared/StarterSharedConfig.swift",
        "Sources/YCAppStarter/Plugins/ProductionReadiness/ProductionReadinessPlugin.swift",
        "Sources/YCAppStarter/Core/Quality/ProductionReadinessModels.swift", "Sources/YCAppStarter/Core/Quality/DefaultProductionReadinessService.swift",
        "Sources/YCAppStarter/Core/Environment/BuildEnvironment.swift", "Sources/YCAppStarter/Core/Analytics/AnalyticsEventCatalog.swift",
        "Sources/YCAppStarter/Modules/ProductionReadiness/ProductionReadinessView.swift", "Sources/YCAppStarter/Modules/EnvironmentDebug/EnvironmentDebugView.swift", "Sources/YCAppStarter/Modules/StoreKitDebug/StoreKitDebugView.swift",
        "Config/Environments/Development.xcconfig", "Config/Environments/Staging.xcconfig", "Config/Environments/Production.xcconfig", "Config/Environments/Secrets.xcconfig.sample",
        "StoreKit/YCAppStarter.storekit", "Scripts/ycstarter.py", "Scripts/setup_config.py", "Scripts/check_stale_version_refs.py", "Scripts/validate_storekit.py", "Scripts/validate_ci.py", "Scripts/appstore_preflight.py", "Scripts/validate_production.py",
        "ci_scripts/ci_post_clone.sh", "ci_scripts/ci_pre_xcodebuild.sh", "ci_scripts/ci_post_xcodebuild.sh",
        "Tests/YCAppStarterTests/FeatureFlagsTests.swift", "Tests/YCAppStarterTests/PluginCatalogTests.swift", "Tests/YCAppStarterTests/AnalyticsEventCatalogTests.swift",
        "Commercial/DeliveryChecklist.md", "Commercial/License/CommercialLicenseTemplate.md",
    ]
    findings.extend(exists(p) for p in required)
    findings.append(Finding("ok" if shutil.which("python3") else "error", "tool.python3", "python3 is available" if shutil.which("python3") else "python3 is missing", "Install Python 3."))
    findings.append(Finding("ok" if shutil.which("xcodegen") else "warning", "tool.xcodegen", "xcodegen is available" if shutil.which("xcodegen") else "xcodegen is not installed", "Install with: brew install xcodegen"))

    catalog, files = plugin_catalog(), plugin_files()
    findings.append(Finding("error" if len(catalog) != len(set(catalog)) else "ok", "plugin.catalogUnique", "PluginCatalog contains duplicate registrations" if len(catalog) != len(set(catalog)) else f"PluginCatalog has {len(catalog)} unique registrations", "Remove duplicate AnyAppPlugin entries."))
    missing_files = sorted(set(catalog) - set(files))
    findings.append(Finding("error" if missing_files else "ok", "plugin.catalogFiles", f"PluginCatalog references missing files: {', '.join(missing_files)}" if missing_files else "PluginCatalog references existing plugin files", "Create missing files or remove registrations."))

    features = feature_cases()
    for feature in ["productionReadiness", "environmentDebug", "storeKitDebug", "ciValidation", "eventCatalog", "releasePackaging"]:
        findings.append(Finding("ok" if feature in features else "error", f"feature.{feature}", f"Feature {feature} exists" if feature in features else f"Feature {feature} is missing", "Update FeatureFlags.swift."))

    project = text("project.yml")
    findings.append(Finding("ok" if "MARKETING_VERSION: 3.1.0" in project and "CURRENT_PROJECT_VERSION: 310" in project else "warning", "version.project", "project.yml is set to 3.1.0 / 310" if "MARKETING_VERSION: 3.1.0" in project else "project.yml version is not 3.1.0 / 310", "Update project.yml before release."))
    for config in ["Development.xcconfig", "Staging.xcconfig", "Production.xcconfig"]:
        findings.append(Finding("ok" if config in project else "error", f"xcconfig.{config}", f"{config} is wired in project.yml" if config in project else f"{config} is not wired in project.yml", "Add settings.configFiles to project.yml."))

    route = text("Sources/YCAppStarter/Core/Routing/AppRoute.swift")
    for case in ["productionReadiness", "environmentDebug", "storeKitDebug"]:
        findings.append(Finding("ok" if case in route else "error", f"route.{case}", f"Route {case} exists" if case in route else f"Route {case} missing", "Update AppRoute.swift and RouteView.swift."))

    try:
        info = plist("Sources/YCAppStarter/Info.plist")
        for key in ["YC_STARTER_ENVIRONMENT", "YC_STARTER_USE_STOREKIT_TEST", "YC_STARTER_ENABLE_VERBOSE_LOGGING", "YC_STARTER_APP_GROUP_IDENTIFIER", "YC_STARTER_URL_SCHEME"]:
            findings.append(Finding("ok" if key in info else "error", f"plist.{key}", f"Info.plist has {key}" if key in info else f"Info.plist missing {key}", "Inject build settings into Info.plist."))
        gad_id = str(info.get("GADApplicationIdentifier", ""))
        findings.append(Finding("warning" if GOOGLE_SAMPLE_AD_PUBLISHER in gad_id else "ok", "plist.admobSample", "Info.plist still references the Google sample AdMob ID" if GOOGLE_SAMPLE_AD_PUBLISHER in gad_id else "Info.plist AdMob App ID appears configured", "Run Scripts/configure_admob.py or setup_config.py --admob-app-id."))
    except Exception as exc:
        findings.append(Finding("error", "plist.parse", f"Info.plist invalid: {exc}", "Fix XML/plist syntax."))

    app_groups = app_groups_from("Sources/YCAppStarter/YCAppStarter.entitlements")
    widget_groups = app_groups_from("Sources/YCAppStarterWidgets/YCAppStarterWidgets.entitlements")
    findings.append(Finding("ok" if app_groups and app_groups == widget_groups else "error", "entitlements.appGroupMatch", "App and widget App Groups match" if app_groups and app_groups == widget_groups else f"App Group mismatch app={app_groups}, widget={widget_groups}", "Run Scripts/setup_config.py init or configure_app_group.py."))
    findings.append(Finding("warning" if DEFAULT_APP_GROUP in app_groups else "ok", "entitlements.defaultAppGroup", "Entitlements still use the template App Group" if DEFAULT_APP_GROUP in app_groups else "App Group is customized or build-setting driven", "Set the final App Group before release."))

    try:
        json.loads((ROOT / "StoreKit/YCAppStarter.storekit").read_text(encoding="utf-8"))
        findings.append(Finding("ok", "storekit.parse", "StoreKit test file parses as JSON"))
    except Exception as exc:
        findings.append(Finding("error", "storekit.parse", f"StoreKit test file is invalid: {exc}", "Fix StoreKit/YCAppStarter.storekit."))

    try:
        rc = json.loads((ROOT / "Sources/YCAppStarter/Resources/RemoteConfigDefaults.json").read_text(encoding="utf-8"))
        required_rc = {"production_readiness_enabled", "ci_validation_required", "storekit_test_enabled", "event_catalog_enforced", "release_packaging_enabled", "minimum_test_coverage_percent", "preflight_block_on_warnings"}
        missing = sorted(required_rc - set(rc))
        findings.append(Finding("error" if missing else "ok", "remoteConfig.v31Keys", f"RemoteConfigDefaults.json missing V3.1 keys: {', '.join(missing)}" if missing else "RemoteConfigDefaults.json contains V3.1 keys", "Restore missing keys."))
    except Exception as exc:
        findings.append(Finding("error", "remoteConfig.parse", f"RemoteConfigDefaults.json invalid: {exc}", "Fix JSON syntax."))

    for script in ["ci_scripts/ci_post_clone.sh", "ci_scripts/ci_pre_xcodebuild.sh", "ci_scripts/ci_post_xcodebuild.sh", "Scripts/ycstarter.py", "Scripts/setup_config.py", "Scripts/check_stale_version_refs.py", "Scripts/validate_storekit.py", "Scripts/validate_ci.py"]:
        path = ROOT / script
        if path.exists():
            findings.append(Finding("ok" if os.access(path, os.X_OK) else "error", f"executable.{script}", f"{script} is executable" if os.access(path, os.X_OK) else f"{script} is not executable", "chmod +x the script."))

    secrets = text("Sources/YCAppStarter/Config/AppSecrets.swift")
    warnings = [
        ('revenueCatAPIKey: ""', 'secrets.revenueCat', 'RevenueCat API key is empty', 'Fill AppSecrets.revenueCatAPIKey before validating purchases.'),
        ('openAIProxyBaseURL: ""', 'secrets.aiProxy', 'AI proxy base URL is empty', 'Run Scripts/configure_ai_proxy.py after deployment.'),
        ('supabaseURL: ""', 'secrets.supabaseURL', 'Supabase URL is empty', 'Run Scripts/configure_supabase.py.'),
        (GOOGLE_SAMPLE_AD_PUBLISHER, 'secrets.admobSample', 'AppSecrets still contains Google sample ad IDs', 'Run Scripts/configure_admob.py before production release.'),
        (DEFAULT_BUNDLE_ID, 'secrets.defaultBundle', 'Project still uses the template bundle identifier', 'Run Scripts/setup_config.py init --bundle-id ...'),
    ]
    for marker, code, msg, fix in warnings:
        findings.append(Finding("warning" if marker in secrets or marker in project else "ok", code, msg if marker in secrets or marker in project else f"{code} appears configured", fix if marker in secrets or marker in project else ""))
    google_plist = ROOT / "Sources/YCAppStarter/Resources/GoogleService-Info.plist"
    findings.append(Finding("ok" if google_plist.exists() else "warning", "secrets.firebase", "GoogleService-Info.plist exists" if google_plist.exists() else "GoogleService-Info.plist is missing", "Download it from Firebase Console and add it to Resources."))

    errors = [f for f in findings if f.level == "error"]
    warn = [f for f in findings if f.level == "warning"]
    if args.json:
        print(json.dumps([f.__dict__ for f in findings], indent=2))
    else:
        print("YCAppStarter Doctor V3.1")
        print("=" * 28)
        for f in findings: print(f.render())
        print("-" * 28)
        print(f"Summary: {len(errors)} error(s), {len(warn)} warning(s), {len(findings)} finding(s)")
    return 1 if errors or (args.strict and warn) else 0

if __name__ == "__main__":
    raise SystemExit(main())
