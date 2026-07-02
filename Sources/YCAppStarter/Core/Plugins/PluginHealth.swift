import Foundation

enum PluginHealthSeverity: Int, Comparable, Hashable {
    case ready = 0
    case info = 1
    case warning = 2
    case error = 3

    static func < (lhs: PluginHealthSeverity, rhs: PluginHealthSeverity) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    var displayName: String {
        switch self {
        case .ready: return "Ready"
        case .info: return "Info"
        case .warning: return "Warning"
        case .error: return "Error"
        }
    }

    var systemImage: String {
        switch self {
        case .ready: return "checkmark.seal.fill"
        case .info: return "info.circle"
        case .warning: return "exclamationmark.triangle.fill"
        case .error: return "xmark.octagon.fill"
        }
    }
}

enum PluginHealthStatus: Hashable {
    case ready
    case disabled(String)
    case missingConfiguration(String)
    case missingDependency(String)
    case missingService(String)
    case warning(String)
    case failed(String)

    var severity: PluginHealthSeverity {
        switch self {
        case .ready: return .ready
        case .disabled: return .info
        case .warning: return .warning
        case .missingConfiguration, .missingDependency, .missingService, .failed: return .error
        }
    }

    var title: String {
        switch self {
        case .ready: return "Ready"
        case .disabled: return "Disabled"
        case .missingConfiguration: return "Missing Configuration"
        case .missingDependency: return "Missing Dependency"
        case .missingService: return "Missing Service"
        case .warning: return "Warning"
        case .failed: return "Failed"
        }
    }

    var message: String {
        switch self {
        case .ready: return "Plugin is enabled and no blocking issue was found."
        case .disabled(let message),
             .missingConfiguration(let message),
             .missingDependency(let message),
             .missingService(let message),
             .warning(let message),
             .failed(let message):
            return message
        }
    }
}

struct PluginHealthCheckResult: Identifiable, Hashable {
    let id: String
    let title: String
    let status: PluginHealthStatus
    let recoverySuggestion: String?

    init(id: String, title: String, status: PluginHealthStatus, recoverySuggestion: String? = nil) {
        self.id = id
        self.title = title
        self.status = status
        self.recoverySuggestion = recoverySuggestion
    }
}

struct PluginHealthReport: Identifiable, Hashable {
    let id: String
    let pluginID: String
    let pluginName: String
    let category: PluginCategory
    let version: StarterVersion
    let status: PluginHealthStatus
    let checks: [PluginHealthCheckResult]

    var worstSeverity: PluginHealthSeverity {
        ([status.severity] + checks.map { $0.status.severity }).max() ?? .ready
    }

    init(
        pluginID: String,
        pluginName: String,
        category: PluginCategory,
        version: StarterVersion,
        status: PluginHealthStatus,
        checks: [PluginHealthCheckResult]
    ) {
        self.id = pluginID
        self.pluginID = pluginID
        self.pluginName = pluginName
        self.category = category
        self.version = version
        self.status = status
        self.checks = checks
    }
}

struct PluginRuntimeSnapshot: Hashable {
    let activePluginCount: Int
    let inactivePluginCount: Int
    let diagnosticCount: Int
    let registeredServices: [String]
    let reports: [PluginHealthReport]

    var hasBlockingIssues: Bool {
        reports.contains { $0.worstSeverity == .error }
    }
}
