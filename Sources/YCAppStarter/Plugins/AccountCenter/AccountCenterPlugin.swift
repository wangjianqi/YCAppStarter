import Foundation

struct AccountCenterPlugin: AppPlugin {
    let descriptor = PluginDescriptor(
        id: "yc.accountCenter",
        displayName: "Account Center",
        version: .v28,
        feature: .accountCenter,
        category: .core,
        dependencies: [.supabaseAuth, .remoteConfig],
        optionalDependencies: [.deepLinks, .pushNotifications, .aiProxy, .revenueCat],
        requiredServices: [ServiceRequirement("AuthManaging"), ServiceRequirement("PrivacyRequestManaging")],
        isRemovable: true,
        summary: "Adds account center, delete-account request, data-export request and privacy request flow surfaces."
    )

    func registerServices(in registry: ServiceRegistry, secrets: AppSecrets, logger: AppLogging) {
        registry.register(PrivacyRequestManaging.self, service: PrivacyRequestManager(logger: logger))
    }

    func makeHomeItems(container: AppContainer) -> [PluginHomeItem] {
        [PluginHomeItem(id: "account-center", title: "Account", subtitle: "Profile and privacy requests", systemImage: "person.crop.circle", route: .accountCenter)]
    }

    func makeSettingsItems(container: AppContainer) -> [PluginSettingsItem] {
        [
            PluginSettingsItem(id: "settings-account-center", title: "Account Center", subtitle: "Manage login, profile and account actions", systemImage: "person.crop.circle", route: .accountCenter),
            PluginSettingsItem(id: "settings-privacy-requests", title: "Privacy Requests", subtitle: "Data export and delete account request flow", systemImage: "hand.raised", route: .privacyRequests)
        ]
    }

    func makeDebugItems(container: AppContainer) -> [PluginDebugItem] {
        let policy = container.service(RemoteConfigServicing.self).map(AccountCenterPolicy.make(from:))
        return [
            PluginDebugItem(id: "account-center-enabled", title: "Account Center", value: policy?.accountCenterEnabled == true ? "Enabled" : "Disabled", systemImage: "person.crop.circle"),
            PluginDebugItem(id: "delete-account-enabled", title: "Delete Account", value: policy?.accountDeletionEnabled == true ? "Enabled" : "Disabled", systemImage: "trash"),
            PluginDebugItem(id: "data-export-enabled", title: "Data Export", value: policy?.dataExportEnabled == true ? "Enabled" : "Disabled", systemImage: "square.and.arrow.up")
        ]
    }

    func makeHealthChecks(container: AppContainer) -> [PluginHealthCheckResult] {
        var checks = AppPluginDefaultHealth.defaultChecks(descriptor: descriptor, container: container)
        checks.append(PluginHealthCheckResult(id: "privacy-request-service", title: "PrivacyRequestManaging service", status: container.services.contains(PrivacyRequestManaging.self) ? .ready : .missingService("PrivacyRequestManaging is not registered."), recoverySuggestion: "Keep AccountCenterPlugin registered."))
        checks.append(PluginHealthCheckResult(id: "account-auth-service", title: "AuthManaging service", status: container.services.contains(AuthManaging.self) ? .ready : .missingService("AuthManaging is not registered."), recoverySuggestion: "Keep SupabaseAuthPlugin enabled when using Account Center."))
        return checks
    }
}
