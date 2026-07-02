import Foundation

struct EntitlementState: Equatable, Sendable {
    let isPremium: Bool
    let activeEntitlementID: String?

    static let free = EntitlementState(isPremium: false, activeEntitlementID: nil)
    static let premium = EntitlementState(isPremium: true, activeEntitlementID: "premium")
}

struct PaywallProduct: Identifiable, Equatable, Sendable {
    let id: String
    let title: String
    let subtitle: String
    let priceText: String
}
