import Foundation

@MainActor
enum AppBootstrapper {
    static func bootstrap() -> AppContainer {
        let config = AppConfig.default
        let flags = FeatureFlags.default
        let secrets = AppSecrets.default
        let services = ServiceRegistry()
        let logger: AppLogging = AppLogger(subsystem: config.bundleIdentifier)
        let catalog = PluginCatalog.makeDefaultCatalog()

        let pluginRuntime = PluginRuntimeFactory.makeRuntime(
            catalog: catalog,
            flags: flags,
            services: services,
            secrets: secrets,
            logger: logger
        )

        let container = AppContainer(
            config: config,
            flags: flags,
            secrets: secrets,
            services: services,
            logger: logger,
            pluginRuntime: pluginRuntime
        )

        return container
    }
}
