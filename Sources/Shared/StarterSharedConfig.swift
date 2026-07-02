import Foundation

enum StarterSharedConfig {
    static var appGroupIdentifier: String {
        string(for: "YC_STARTER_APP_GROUP_IDENTIFIER", fallback: "group.com.yuechuanlabs.ycappstarter")
    }

    static var urlScheme: String {
        string(for: "YC_STARTER_URL_SCHEME", fallback: "ycappstarter")
    }

    private static func string(for key: String, fallback: String) -> String {
        guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? String else { return fallback }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty || trimmed.hasPrefix("$(") { return fallback }
        return trimmed
    }
}
