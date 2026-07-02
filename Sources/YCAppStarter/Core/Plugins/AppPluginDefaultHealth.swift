import Foundation

@MainActor
enum AppPluginDefaultHealth {
    static func defaultChecks(descriptor: PluginDescriptor, container: AppContainer) -> [PluginHealthCheckResult] {
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
