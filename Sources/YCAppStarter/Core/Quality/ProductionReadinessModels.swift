import Foundation

enum ProductionCheckSeverity: String, CaseIterable, Identifiable {
    case pass
    case warning
    case blocking

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .pass: return "Pass"
        case .warning: return "Warning"
        case .blocking: return "Blocking"
        }
    }

    var systemImage: String {
        switch self {
        case .pass: return "checkmark.seal"
        case .warning: return "exclamationmark.triangle"
        case .blocking: return "xmark.octagon"
        }
    }
}

struct ProductionReadinessCheck: Identifiable, Hashable {
    let id: String
    let title: String
    let detail: String
    let severity: ProductionCheckSeverity
    let recovery: String
}

struct ProductionReadinessReport: Hashable {
    let checks: [ProductionReadinessCheck]

    var blockingCount: Int { checks.filter { $0.severity == .blocking }.count }
    var warningCount: Int { checks.filter { $0.severity == .warning }.count }
    var passedCount: Int { checks.filter { $0.severity == .pass }.count }
    var isReleaseReady: Bool { blockingCount == 0 }

    var score: Int {
        guard !checks.isEmpty else { return 0 }
        return Int((Double(passedCount) / Double(checks.count)) * 100.0)
    }
}

protocol ProductionReadinessServicing: Sendable {
    func makeReport(container: AppContainer) -> ProductionReadinessReport
}
