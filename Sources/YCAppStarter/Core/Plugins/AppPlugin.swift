import Foundation

@MainActor
protocol AppPlugin {
    var descriptor: PluginDescriptor { get }

    func registerServices(in registry: ServiceRegistry, secrets: AppSecrets, logger: AppLogging)
    func configure(container: AppContainer) async
    func makeHomeItems(container: AppContainer) -> [PluginHomeItem]
    func makeSettingsItems(container: AppContainer) -> [PluginSettingsItem]
    func makeDebugItems(container: AppContainer) -> [PluginDebugItem]
    func healthStatus(container: AppContainer) -> PluginHealthStatus
    func makeHealthChecks(container: AppContainer) -> [PluginHealthCheckResult]
}

extension AppPlugin {
    func registerServices(in registry: ServiceRegistry, secrets: AppSecrets, logger: AppLogging) {}
    func configure(container: AppContainer) async {}
    func makeHomeItems(container: AppContainer) -> [PluginHomeItem] { [] }
    func makeSettingsItems(container: AppContainer) -> [PluginSettingsItem] { [] }
    func makeDebugItems(container: AppContainer) -> [PluginDebugItem] { [] }

    func healthStatus(container: AppContainer) -> PluginHealthStatus {
        let blockingChecks = makeHealthChecks(container: container).filter { $0.status.severity == .error }
        if let firstBlockingCheck = blockingChecks.first {
            return firstBlockingCheck.status
        }

        let warningChecks = makeHealthChecks(container: container).filter { $0.status.severity == .warning }
        if let firstWarningCheck = warningChecks.first {
            return firstWarningCheck.status
        }

        return .ready
    }

    func makeHealthChecks(container: AppContainer) -> [PluginHealthCheckResult] {
        descriptor.requiredSecrets.map { secret in
            PluginHealthCheckResult(
                id: "secret-\(secret.rawValue)",
                title: secret.displayName,
                status: container.secrets.hasValue(for: secret) ? .ready : .missingConfiguration("\(secret.displayName) is not configured."),
                recoverySuggestion: "Fill the value in Config/AppSecrets.swift or provide an environment-specific secrets file."
            )
        }
    }
}
