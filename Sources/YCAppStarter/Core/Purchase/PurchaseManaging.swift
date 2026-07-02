import Foundation

@MainActor
protocol PurchaseManaging {
    var entitlement: EntitlementState { get }
    var products: [PaywallProduct] { get }

    func configure() async
    func purchase(productID: String) async throws
    func restore() async throws
}
