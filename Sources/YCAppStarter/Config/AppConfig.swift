import SwiftUI

struct AppConfig {
    let displayName: String
    let bundleIdentifier: String
    let supportEmail: String
    let theme: AppTheme
    let appearance: AppAppearance
    let legalLinks: LegalLinks

    static let `default` = AppConfig(
        displayName: "YCAppStarter",
        bundleIdentifier: "com.yuechuanlabs.ycappstarter",
        supportEmail: "support@example.com",
        theme: .default,
        appearance: .system,
        legalLinks: .default
    )
}

enum AppAppearance: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var preferredColorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}
