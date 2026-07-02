import Foundation

enum BuildEnvironment: String, CaseIterable, Identifiable {
    case development
    case staging
    case production

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .development: return "Development"
        case .staging: return "Staging"
        case .production: return "Production"
        }
    }

    var defaultAllowsVerboseLogging: Bool { self != .production }
    var defaultShouldUseStoreKitTest: Bool { self == .development }
}

struct BuildEnvironmentReader {
    static var current: BuildEnvironment {
        if let value = stringInfo("YC_STARTER_ENVIRONMENT"),
           let environment = BuildEnvironment(rawValue: value.lowercased()) {
            return environment
        }
        #if DEBUG
        return .development
        #else
        return .production
        #endif
    }

    static var allowsVerboseLogging: Bool {
        boolInfo("YC_STARTER_ENABLE_VERBOSE_LOGGING") ?? current.defaultAllowsVerboseLogging
    }

    static var shouldUseStoreKitTest: Bool {
        boolInfo("YC_STARTER_USE_STOREKIT_TEST") ?? current.defaultShouldUseStoreKitTest
    }

    static var rawInfo: [String: String] {
        [
            "environment": current.rawValue,
            "verboseLogging": allowsVerboseLogging ? "true" : "false",
            "storeKitTest": shouldUseStoreKitTest ? "true" : "false"
        ]
    }

    private static func stringInfo(_ key: String) -> String? {
        guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? String else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !trimmed.hasPrefix("$(") else { return nil }
        return trimmed
    }

    private static func boolInfo(_ key: String) -> Bool? {
        guard let value = stringInfo(key)?.lowercased() else { return nil }
        switch value {
        case "yes", "true", "1": return true
        case "no", "false", "0": return false
        default: return nil
        }
    }
}
