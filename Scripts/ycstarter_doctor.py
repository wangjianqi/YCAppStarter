#!/usr/bin/env python3
from __future__ import annotations
import argparse, json, plistlib, re, shutil, os
from dataclasses import dataclass
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
@dataclass
class Finding:
    level: str; code: str; message: str; recovery: str = ""
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
def main() -> int:
    parser = argparse.ArgumentParser(description="Run static checks for YCAppStarter V3.0.")
    parser.add_argument("--json", action="store_true")
    parser.add_argument("--strict", action="store_true")
    args = parser.parse_args()
    findings: list[Finding] = []
    required = [
        "project.yml", ".starter-version", "Sources/YCAppStarter/Info.plist", "Sources/YCAppStarter/YCAppStarter.entitlements",
        "Sources/YCAppStarter/Plugins/ProductionReadiness/ProductionReadinessPlugin.swift",
        "Sources/YCAppStarter/Core/Quality/ProductionReadinessModels.swift", "Sources/YCAppStarter/Core/Quality/DefaultProductionReadinessService.swift",
        "Sources/YCAppStarter/Core/Environment/BuildEnvironment.swift", "Sources/YCAppStarter/Core/Analytics/AnalyticsEventCatalog.swift",
        "Sources/YCAppStarter/Modules/ProductionReadiness/ProductionReadinessView.swift", "Sources/YCAppStarter/Modules/EnvironmentDebug/EnvironmentDebugView.swift", "Sources/YCAppStarter/Modules/StoreKitDebug/StoreKitDebugView.swift",
        "Config/Environments/Development.xcconfig", "Config/Environments/Staging.xcconfig", "Config/Environments/Production.xcconfig", "Config/Environments/Secrets.xcconfig.sample",
        "StoreKit/YCAppStarter.storekit", "Scripts/ycstarter.py", "Scripts/validate_storekit.py", "Scripts/validate_ci.py", "Scripts/appstore_preflight.py", "Scripts/validate_production.py",
        "ci_scripts/ci_post_clone.sh", "ci_scripts/ci_pre_xcodebuild.sh", "ci_scripts/ci_post_xcodebuild.sh",
        "Tests/YCAppStarterTests/FeatureFlagsTests.swift", "Tests/YCAppStarterTests/PluginCatalogTests.swift", "Tests/YCAppStarterTests/AnalyticsEventCatalogTests.swift",
        "Commercial/DeliveryChecklist.md", "Commercial/License/CommercialLicenseTemplate.md"
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
    findings.append(Finding("ok" if "MARKETING_VERSION: 3.0.0" in project and "CURRENT_PROJECT_VERSION: 300" in project else "warning", "version.project", "project.yml is set to 3.0.0 / 300" if "MARKETING_VERSION: 3.0.0" in project else "project.yml version is not 3.0.0 / 300", "Update project.yml before release."))
    findings.append(Finding("ok" if "YCAppStarterTests" in project else "error", "target.tests", "Unit test target exists" if "YCAppStarterTests" in project else "Unit test target missing", "Add YCAppStarterTests target to project.yml."))
    route = text("Sources/YCAppStarter/Core/Routing/AppRoute.swift")
    for case in ["productionReadiness", "environmentDebug", "storeKitDebug"]:
        findings.append(Finding("ok" if case in route else "error", f"route.{case}", f"Route {case} exists" if case in route else f"Route {case} missing", "Update AppRoute.swift and RouteView.swift."))
    try:
        json.loads((ROOT / "StoreKit/YCAppStarter.storekit").read_text(encoding="utf-8"))
        findings.append(Finding("ok", "storekit.parse", "StoreKit test file parses as JSON"))
    except Exception as exc:
        findings.append(Finding("error", "storekit.parse", f"StoreKit test file is invalid: {exc}", "Fix StoreKit/YCAppStarter.storekit."))
    try:
        rc = json.loads((ROOT / "Sources/YCAppStarter/Resources/RemoteConfigDefaults.json").read_text(encoding="utf-8"))
        missing = sorted({"production_readiness_enabled", "ci_validation_required", "storekit_test_enabled", "event_catalog_enforced", "release_packaging_enabled"} - set(rc))
        findings.append(Finding("error" if missing else "ok", "remoteConfig.v30Keys", f"RemoteConfigDefaults.json missing V3.0 keys: {', '.join(missing)}" if missing else "RemoteConfigDefaults.json contains V3.0 keys", "Restore missing keys."))
    except Exception as exc:
        findings.append(Finding("error", "remoteConfig.parse", f"RemoteConfigDefaults.json invalid: {exc}", "Fix JSON syntax."))
    for script in ["ci_scripts/ci_post_clone.sh", "ci_scripts/ci_pre_xcodebuild.sh", "ci_scripts/ci_post_xcodebuild.sh", "Scripts/ycstarter.py", "Scripts/validate_storekit.py", "Scripts/validate_ci.py"]:
        path = ROOT / script
        if path.exists():
            findings.append(Finding("ok" if os.access(path, os.X_OK) else "error", f"executable.{script}", f"{script} is executable" if os.access(path, os.X_OK) else f"{script} is not executable", "chmod +x the script."))
    secrets = text("Sources/YCAppStarter/Config/AppSecrets.swift")
    warnings = [
        ('revenueCatAPIKey: ""', 'secrets.revenueCat', 'RevenueCat API key is empty', 'Fill AppSecrets.revenueCatAPIKey before validating purchases.'),
        ('openAIProxyBaseURL: ""', 'secrets.aiProxy', 'AI proxy base URL is empty', 'Run Scripts/configure_ai_proxy.py after deployment.'),
        ('supabaseURL: ""', 'secrets.supabaseURL', 'Supabase URL is empty', 'Run Scripts/configure_supabase.py.'),
        ('3940256099942544', 'secrets.admobSample', 'AppSecrets still contains Google sample ad IDs', 'Run Scripts/configure_admob.py before production release.'),
    ]
    for marker, code, msg, fix in warnings:
        findings.append(Finding("warning" if marker in secrets else "ok", code, msg if marker in secrets else f"{code} appears configured", fix if marker in secrets else ""))
    google_plist = ROOT / "Sources/YCAppStarter/Resources/GoogleService-Info.plist"
    findings.append(Finding("ok" if google_plist.exists() else "warning", "secrets.firebase", "GoogleService-Info.plist exists" if google_plist.exists() else "GoogleService-Info.plist is missing", "Download it from Firebase Console and add it to Resources."))
    errors = [f for f in findings if f.level == "error"]
    warn = [f for f in findings if f.level == "warning"]
    if args.json:
        print(json.dumps([f.__dict__ for f in findings], indent=2))
    else:
        print("YCAppStarter Doctor V3.0")
        print("=" * 28)
        for f in findings: print(f.render())
        print("-" * 28)
        print(f"Summary: {len(errors)} error(s), {len(warn)} warning(s), {len(findings)} finding(s)")
    return 1 if errors or (args.strict and warn) else 0
if __name__ == "__main__":
    raise SystemExit(main())
