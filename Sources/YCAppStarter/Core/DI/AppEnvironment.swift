import Foundation

enum AppEnvironment: String, CaseIterable, Identifiable {
    case development
    case staging
    case production

    var id: String { rawValue }
}
