import Foundation

struct AppStoreChecklistItem: Identifiable, Hashable {
    enum Status: String, Hashable {
        case passed
        case warning
        case failed
        case manual

        var title: String {
            switch self {
            case .passed: return "Passed"
            case .warning: return "Warning"
            case .failed: return "Failed"
            case .manual: return "Manual"
            }
        }

        var systemImage: String {
            switch self {
            case .passed: return "checkmark.seal.fill"
            case .warning: return "exclamationmark.triangle.fill"
            case .failed: return "xmark.octagon.fill"
            case .manual: return "checklist"
            }
        }
    }

    let id: String
    let title: String
    let detail: String
    let status: Status
    let recoverySuggestion: String
    let category: AppStoreChecklistCategory
}

enum AppStoreChecklistCategory: String, CaseIterable, Identifiable, Hashable {
    case identity
    case legal
    case monetization
    case analytics
    case privacy
    case localization
    case ads
    case review

    var id: String { rawValue }

    var title: String {
        switch self {
        case .identity: return "Identity"
        case .legal: return "Legal"
        case .monetization: return "Monetization"
        case .analytics: return "Analytics"
        case .privacy: return "Privacy"
        case .localization: return "Localization"
        case .ads: return "Ads"
        case .review: return "Review"
        }
    }
}

struct AppStoreReadinessReport: Hashable {
    let items: [AppStoreChecklistItem]

    var passedCount: Int { items.filter { $0.status == .passed }.count }
    var warningCount: Int { items.filter { $0.status == .warning }.count }
    var failedCount: Int { items.filter { $0.status == .failed }.count }
    var manualCount: Int { items.filter { $0.status == .manual }.count }

    var score: Int {
        guard items.isEmpty == false else { return 0 }
        return Int((Double(passedCount) / Double(items.count)) * 100.0)
    }

    func items(in category: AppStoreChecklistCategory) -> [AppStoreChecklistItem] {
        items.filter { $0.category == category }
    }
}

struct MetadataTemplate: Identifiable, Hashable {
    let id: String
    let title: String
    let filename: String
    let summary: String
    let path: String
}

struct PrivacyManifestAuditResult: Identifiable, Hashable {
    let id: String
    let title: String
    let status: AppStoreChecklistItem.Status
    let message: String
    let recoverySuggestion: String
}

struct LocalizationAuditResult: Identifiable, Hashable {
    let id: String
    let title: String
    let status: AppStoreChecklistItem.Status
    let message: String
    let recoverySuggestion: String
}
