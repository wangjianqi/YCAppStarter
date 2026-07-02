import Foundation
import Combine

@MainActor
final class PaywallViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let purchaseManager: PurchaseManaging?

    init(purchaseManager: PurchaseManaging?) {
        self.purchaseManager = purchaseManager
    }

    var products: [PaywallProduct] {
        purchaseManager?.products ?? []
    }

    func purchase(productID: String) async {
        guard let purchaseManager else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            try await purchaseManager.purchase(productID: productID)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func restore() async {
        guard let purchaseManager else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            try await purchaseManager.restore()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
