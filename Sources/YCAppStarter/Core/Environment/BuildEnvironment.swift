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

    var allowsVerboseLogging: Bool { self != .production }
    var shouldUseStoreKitTest: Bool { self == .development }
}

struct BuildEnvironmentReader {
    static var current: BuildEnvironment {
        if let value = Bundle.main.object(forInfoDictionaryKey: "YC_STARTER_ENVIRONMENT") as? String,
           let environment = BuildEnvironment(rawValue: value.lowercased()) {
            return environment
        }
        #if DEBUG
        return .development
        #else
        return .production
        #endif
    }

    static var rawInfo: [String: String] {
        [
            "environment": current.rawValue,
            "verboseLogging": current.allowsVerboseLogging ? "true" : "false",
            "storeKitTest": current.shouldUseStoreKitTest ? "true" : "false"
        ]
    }
}
