import Foundation
import Combine

@MainActor
final class AppContainer: ObservableObject {
    let config: AppConfig
    let flags: FeatureFlags
    let secrets: AppSecrets
    let services: ServiceRegistry
    let logger: AppLogging
    let router = AppRouter()
    let pluginRuntime: PluginRuntime

    init(
        config: AppConfig,
        flags: FeatureFlags,
        secrets: AppSecrets,
        services: ServiceRegistry,
        logger: AppLogging,
        pluginRuntime: PluginRuntime
    ) {
        self.config = config
        self.flags = flags
        self.secrets = secrets
        self.services = services
        self.logger = logger
        self.pluginRuntime = pluginRuntime
    }

    var plugins: [AnyAppPlugin] {
        pluginRuntime.activePlugins
    }

    func configureOnLaunch() async {
        logger.info("App launched: \(config.displayName)")
        await pluginRuntime.configure(container: self)
    }

    func service<Service>(_ type: Service.Type) -> Service? {
        services.resolve(type)
    }

    func requireService<Service>(_ type: Service.Type) -> Service {
        services.require(type)
    }
}
