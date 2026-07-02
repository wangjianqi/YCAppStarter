import Foundation

@MainActor
enum PluginGraph {
    struct ResolutionResult {
        let activePlugins: [AnyAppPlugin]
        let inactivePlugins: [PluginDescriptor]
        let diagnostics: [PluginDiagnostic]
    }

    static func resolve(catalog: [AnyAppPlugin], flags: FeatureFlags) -> ResolutionResult {
        var active: [AnyAppPlugin] = []
        var inactive: [PluginDescriptor] = []
        var diagnostics: [PluginDiagnostic] = []
        let enabledFeatures = Set(flags.enabled)
        let catalogFeatures = Set(catalog.map { $0.descriptor.feature })
        let duplicatePluginIDs = Dictionary(grouping: catalog, by: { $0.descriptor.id }).filter { $0.value.count > 1 }
        let duplicateFeatures = Dictionary(grouping: catalog, by: { $0.descriptor.feature }).filter { $0.value.count > 1 }

        for id in duplicatePluginIDs.keys.sorted() {
            diagnostics.append(
                PluginDiagnostic(
                    level: .error,
                    pluginID: id,
                    message: "Duplicate plugin id found in PluginCatalog: \(id)"
                )
            )
        }

        for feature in duplicateFeatures.keys.sorted(by: { $0.rawValue < $1.rawValue }) {
            diagnostics.append(
                PluginDiagnostic(
                    level: .warning,
                    pluginID: feature.rawValue,
                    message: "Multiple plugins declare the same feature: \(feature.rawValue)"
                )
            )
        }

        for plugin in catalog {
            let descriptor = plugin.descriptor

            guard flags.isEnabled(descriptor.feature) else {
                inactive.append(descriptor)
                continue
            }

            let unknownDependencies = descriptor.dependencies.filter { !catalogFeatures.contains($0) }
            if !unknownDependencies.isEmpty {
                inactive.append(descriptor)
                diagnostics.append(
                    PluginDiagnostic(
                        level: .error,
                        pluginID: descriptor.id,
                        message: "Disabled because dependency plugins are not in PluginCatalog: \(unknownDependencies.map { $0.rawValue }.joined(separator: ", "))"
                    )
                )
                continue
            }

            let missingDependencies = descriptor.dependencies.filter { !enabledFeatures.contains($0) }
            if missingDependencies.isEmpty {
                active.append(plugin)
            } else {
                inactive.append(descriptor)
                diagnostics.append(
                    PluginDiagnostic(
                        level: .warning,
                        pluginID: descriptor.id,
                        message: "Disabled because missing enabled dependencies: \(missingDependencies.map { $0.rawValue }.joined(separator: ", "))"
                    )
                )
            }
        }

        return ResolutionResult(activePlugins: active, inactivePlugins: inactive, diagnostics: diagnostics)
    }
}

struct PluginDiagnostic: Identifiable, Hashable {
    enum Level: String, Hashable {
        case info
        case warning
        case error

        var displayName: String { rawValue.capitalized }

        var systemImage: String {
            switch self {
            case .info: return "info.circle"
            case .warning: return "exclamationmark.triangle"
            case .error: return "xmark.octagon"
            }
        }
    }

    let id = UUID()
    let level: Level
    let pluginID: String
    let message: String
}
