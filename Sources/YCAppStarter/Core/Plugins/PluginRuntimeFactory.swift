import Foundation

@MainActor
enum PluginRuntimeFactory {
    static func makeRuntime(
        catalog: [AnyAppPlugin],
        flags: FeatureFlags,
        services: ServiceRegistry,
        secrets: AppSecrets,
        logger: AppLogging
    ) -> PluginRuntime {
        let result = PluginGraph.resolve(catalog: catalog, flags: flags)

        for plugin in result.activePlugins {
            plugin.registerServices(in: services, secrets: secrets, logger: logger)
        }

        logger.info("Active plugins: \(result.activePlugins.map { $0.descriptor.id }.joined(separator: ", "))")

        return PluginRuntime(
            activePlugins: result.activePlugins,
            inactivePlugins: result.inactivePlugins,
            diagnostics: result.diagnostics
        )
    }
}
