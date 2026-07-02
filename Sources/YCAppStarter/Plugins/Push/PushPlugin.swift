import Foundation

struct PushPlugin: AppPlugin {
    let descriptor = PluginDescriptor(
        id: "yc.push",
        displayName: "Push Notifications",
        version: .v28,
        feature: .pushNotifications,
        category: .growth,
        dependencies: [.firebase, .remoteConfig],
        optionalDependencies: [.deepLinks, .supabaseAuth],
        requiredSecrets: [.firebaseGoogleServiceInfo, .apnsEnvironment],
        requiredServices: [
            ServiceRequirement("PushManaging"),
            ServiceRequirement("RemoteConfigServicing")
        ],
        isRemovable: true,
        summary: "Adds APNs/Firebase Messaging push registration, token diagnostics and notification policy gates."
    )

    func registerServices(in registry: ServiceRegistry, secrets: AppSecrets, logger: AppLogging) {
        registry.register(PushManaging.self, service: FirebasePushManager(secrets: secrets, logger: logger))
    }

    func configure(container: AppContainer) async {
        await container.service(PushManaging.self)?.configure(container: container)
    }

    func makeHomeItems(container: AppContainer) -> [PluginHomeItem] {
        [PluginHomeItem(id: "push-debug", title: "Push", subtitle: "APNs and FCM registration", systemImage: "bell.badge", route: .pushDebug)]
    }

    func makeSettingsItems(container: AppContainer) -> [PluginSettingsItem] {
        [PluginSettingsItem(id: "settings-push-debug", title: "Push Notifications", subtitle: "APNs, FCM and authorization state", systemImage: "bell.badge", route: .pushDebug)]
    }

    func makeDebugItems(container: AppContainer) -> [PluginDebugItem] {
        let push = container.service(PushManaging.self)
        let policy = container.service(RemoteConfigServicing.self).map(PushLaunchPolicy.make(from:))
        return [
            PluginDebugItem(id: "push-service", title: "Push Service", value: push == nil ? "Missing" : "Registered", systemImage: "bell"),
            PluginDebugItem(id: "push-policy", title: "Push Enabled", value: policy?.isPushEnabled == true ? "true" : "false", systemImage: "switch.2"),
            PluginDebugItem(id: "push-auth", title: "Authorization", value: push?.snapshot.authorizationState.displayName ?? "Unknown", systemImage: "checkmark.seal"),
            PluginDebugItem(id: "push-fcm", title: "FCM Token", value: push?.snapshot.fcmTokenPreview ?? "None", systemImage: "key")
        ]
    }

    func makeHealthChecks(container: AppContainer) -> [PluginHealthCheckResult] {
        var checks = AppPluginDefaultHealth.defaultChecks(descriptor: descriptor, container: container)
        let push = container.service(PushManaging.self)
        let policy = container.service(RemoteConfigServicing.self).map(PushLaunchPolicy.make(from:))
        checks.append(PluginHealthCheckResult(id: "push-service", title: "PushManaging service", status: push == nil ? .missingService("PushManaging is not registered.") : .ready, recoverySuggestion: "Keep PushPlugin registered in PluginCatalog."))
        checks.append(PluginHealthCheckResult(id: "push-policy", title: "Push Remote Policy", status: policy?.isPushEnabled == true ? .ready : .warning("Push is disabled by Remote Config, Review Safe Mode or Kill Switch."), recoverySuggestion: "Set push_enabled=true when validating push flows."))
        checks.append(PluginHealthCheckResult(id: "push-firebase", title: "Firebase Messaging Config", status: push?.isConfigured == true ? .ready : .missingConfiguration("GoogleService-Info.plist is missing."), recoverySuggestion: "Add GoogleService-Info.plist to Resources and enable Firebase Messaging in Firebase Console."))
        return checks
    }
}
