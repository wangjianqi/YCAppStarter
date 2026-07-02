import Foundation

enum PaywallTemplate: String, CaseIterable, Identifiable {
    case minimal
    case visualHero
    case comparison

    var id: String { rawValue }

    static func resolve(_ rawValue: String) -> PaywallTemplate {
        PaywallTemplate(rawValue: rawValue) ?? .minimal
    }

    var title: String {
        switch self {
        case .minimal: return "Minimal"
        case .visualHero: return "Visual Hero"
        case .comparison: return "Comparison"
        }
    }
}

struct PaywallBenefit: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let subtitle: String
    let systemImage: String

    static let starterDefaults: [PaywallBenefit] = [
        PaywallBenefit(title: "All premium features", subtitle: "Use every paid feature without per-feature gating.", systemImage: "sparkles"),
        PaywallBenefit(title: "Export without limits", subtitle: "A sensible default benefit for media and utility apps.", systemImage: "square.and.arrow.up"),
        PaywallBenefit(title: "Priority updates", subtitle: "Ship new monetized features behind one entitlement.", systemImage: "bolt.fill")
    ]
}
