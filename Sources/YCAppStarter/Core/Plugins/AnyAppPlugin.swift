import Foundation

@MainActor
struct AnyAppPlugin: Identifiable {
    let id: String
    let descriptor: PluginDescriptor

    private let registerServicesClosure: (ServiceRegistry, AppSecrets, AppLogging) -> Void
    private let configureClosure: (AppContainer) async -> Void
    private let homeItemsClosure: (AppContainer) -> [PluginHomeItem]
    private let settingsItemsClosure: (AppContainer) -> [PluginSettingsItem]
    private let debugItemsClosure: (AppContainer) -> [PluginDebugItem]
    private let healthStatusClosure: (AppContainer) -> PluginHealthStatus
    private let healthChecksClosure: (AppContainer) -> [PluginHealthCheckResult]

    init<Plugin: AppPlugin>(_ plugin: Plugin) {
        self.id = plugin.descriptor.id
        self.descriptor = plugin.descriptor
        self.registerServicesClosure = plugin.registerServices
        self.configureClosure = plugin.configure
        self.homeItemsClosure = plugin.makeHomeItems
        self.settingsItemsClosure = plugin.makeSettingsItems
        self.debugItemsClosure = plugin.makeDebugItems
        self.healthStatusClosure = plugin.healthStatus
        self.healthChecksClosure = plugin.makeHealthChecks
    }

    func registerServices(in registry: ServiceRegistry, secrets: AppSecrets, logger: AppLogging) {
        registerServicesClosure(registry, secrets, logger)
    }

    func configure(container: AppContainer) async {
        await configureClosure(container)
    }

    func makeHomeItems(container: AppContainer) -> [PluginHomeItem] {
        homeItemsClosure(container)
    }

    func makeSettingsItems(container: AppContainer) -> [PluginSettingsItem] {
        settingsItemsClosure(container)
    }

    func makeDebugItems(container: AppContainer) -> [PluginDebugItem] {
        debugItemsClosure(container)
    }

    func healthStatus(container: AppContainer) -> PluginHealthStatus {
        healthStatusClosure(container)
    }

    func makeHealthChecks(container: AppContainer) -> [PluginHealthCheckResult] {
        healthChecksClosure(container)
    }

    func makeHealthReport(container: AppContainer) -> PluginHealthReport {
        PluginHealthReport(
            pluginID: descriptor.id,
            pluginName: descriptor.displayName,
            category: descriptor.category,
            version: descriptor.version,
            status: healthStatus(container: container),
            checks: makeHealthChecks(container: container)
        )
    }
}
