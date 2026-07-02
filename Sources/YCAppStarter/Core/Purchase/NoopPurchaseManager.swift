import Foundation
import Combine

@MainActor
final class NoopPurchaseManager: ObservableObject, PurchaseManaging {
    @Published private(set) var entitlement: EntitlementState = .free

    let products: [PaywallProduct] = [
        PaywallProduct(id: "lifetime", title: "Lifetime", subtitle: "Unlock all V1/V2 starter features", priceText: "$1.99")
    ]

    func configure() async {}

    func purchase(productID: String) async throws {
        entitlement = .premium
    }

    func restore() async throws {}
}
