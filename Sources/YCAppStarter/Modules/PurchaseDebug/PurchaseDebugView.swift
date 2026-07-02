import SwiftUI

struct PurchaseDebugView: View {
    @EnvironmentObject private var container: AppContainer
    @State private var isRefreshing = false
    @State private var lastAction = "No purchase action yet"

    private var purchase: PurchaseManaging? {
        container.service(PurchaseManaging.self)
    }

    var body: some View {
        List {
            Section("Provider") {
                LabeledContent("PurchaseManaging", value: purchase == nil ? "Missing" : "Registered")
                LabeledContent("RevenueCat Key", value: container.secrets.hasValue(for: .revenueCatAPIKey) ? "Configured" : "Missing")
                LabeledContent("Entitlement", value: container.secrets.revenueCatEntitlementID)
                LabeledContent("Premium", value: purchase?.entitlement.isPremium == true ? "Yes" : "No")
            }

            Section("Products") {
                if let products = purchase?.products, !products.isEmpty {
                    ForEach(products) { product in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(product.title)
                                .font(.headline)
                            Text(product.subtitle)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            LabeledContent("ID", value: product.id)
                            LabeledContent("Price", value: product.priceText)
                        }
                        .padding(.vertical, 4)
                    }
                } else {
                    Text("No products loaded. Check RevenueCat offering, product IDs, App Store Connect status, StoreKit config, and sandbox account.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            Section("Actions") {
                Button {
                    Task { await restore() }
                } label: {
                    Label("Restore Purchases", systemImage: "arrow.clockwise")
                }
                .disabled(isRefreshing || purchase == nil)

                Text(lastAction)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Purchase Debug")
    }

    private func restore() async {
        guard let purchase else { return }
        isRefreshing = true
        defer { isRefreshing = false }
        do {
            try await purchase.restore()
            lastAction = "Restore completed"
        } catch {
            lastAction = error.localizedDescription
        }
    }
}
