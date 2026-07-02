import SwiftUI

struct PaywallView: View {
    @EnvironmentObject private var container: AppContainer
    @State private var template: PaywallTemplate = .visualHero
    @State private var isLoading = false
    @State private var errorMessage: String?

    private var purchaseManager: PurchaseManaging? {
        container.service(PurchaseManaging.self)
    }

    private var remoteConfig: RemoteConfigServicing? {
        container.service(RemoteConfigServicing.self)
    }

    private var products: [PaywallProduct] {
        purchaseManager?.products ?? []
    }

    var body: some View {
        ScrollView {
            VStack(spacing: DesignTokens.Spacing.lg) {
                if remoteConfig?.isPaywallEnabled == false {
                    EmptyStateView(
                        title: "Paywall suppressed",
                        message: "Remote Config disabled paywall_enabled or enabled Review Safe Mode / Kill Switch.",
                        systemImage: "shield.lefthalf.filled"
                    )
                }

                Picker("Template", selection: $template) {
                    ForEach(PaywallTemplate.allCases) { template in
                        Text(template.title).tag(template)
                    }
                }
                .pickerStyle(.segmented)

                if remoteConfig?.isPaywallEnabled != false {
                    switch template {
                    case .minimal:
                    MinimalPaywallTemplate(products: products, isLoading: isLoading, purchase: purchase)
                case .visualHero:
                    VisualHeroPaywallTemplate(products: products, isLoading: isLoading, purchase: purchase, restore: restore)
                    case .comparison:
                        ComparisonPaywallTemplate(products: products, isLoading: isLoading, purchase: purchase, restore: restore)
                    }
                }

                if products.isEmpty && remoteConfig?.isPaywallEnabled != false {
                    EmptyStateView(
                        title: "No products loaded",
                        message: "V2.2 can use RevenueCat when configured. Fill revenueCatAPIKey, configure offerings, then check Purchase Debug.",
                        systemImage: "cart.badge.questionmark"
                    )
                }
            }
            .padding(DesignTokens.Spacing.lg)
        }
        .navigationTitle("Upgrade")
        .onAppear {
            if let remoteConfig {
                template = PaywallTemplate.resolve(remoteConfig.paywallVariant)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    container.router.push(.purchaseDebug)
                } label: {
                    Image(systemName: "ladybug")
                }
            }
        }
        .alert("Purchase Error", isPresented: Binding(get: { errorMessage != nil }, set: { _ in errorMessage = nil })) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "Unknown error")
        }
    }

    private func purchase(productID: String) {
        Task {
            guard let purchaseManager else { return }
            isLoading = true
            defer { isLoading = false }
            do {
                try await purchaseManager.purchase(productID: productID)
                container.service(AnalyticsTracking.self)?.track(AnalyticsEvent("purchase_success", parameters: ["product_id": productID]))
            } catch {
                errorMessage = error.localizedDescription
                container.service(CrashReporting.self)?.record(error: error, userInfo: ["flow": "paywall_purchase", "product_id": productID])
            }
        }
    }

    private func restore() {
        Task {
            guard let purchaseManager else { return }
            isLoading = true
            defer { isLoading = false }
            do {
                try await purchaseManager.restore()
                container.service(AnalyticsTracking.self)?.track(AnalyticsEvent("purchase_restore_success"))
            } catch {
                errorMessage = error.localizedDescription
                container.service(CrashReporting.self)?.record(error: error, userInfo: ["flow": "paywall_restore"])
            }
        }
    }
}

private struct MinimalPaywallTemplate: View {
    let products: [PaywallProduct]
    let isLoading: Bool
    let purchase: (String) -> Void

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                Text("Upgrade to Pro")
                    .font(.largeTitle.bold())
                Text("A clean utility paywall for simple tools.")
                    .foregroundStyle(.secondary)

                productButtons
            }
        }
    }

    private var productButtons: some View {
        VStack(spacing: DesignTokens.Spacing.sm) {
            ForEach(products) { product in
                PrimaryButton("\(product.title) · \(product.priceText)", systemImage: "crown.fill") {
                    purchase(product.id)
                }
                .disabled(isLoading)
            }
        }
    }
}

private struct VisualHeroPaywallTemplate: View {
    let products: [PaywallProduct]
    let isLoading: Bool
    let purchase: (String) -> Void
    let restore: () -> Void

    var body: some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            AppCard {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                    Image(systemName: "sparkles.rectangle.stack.fill")
                        .font(.system(size: 48))
                    Text("Unlock the full starter experience")
                        .font(.largeTitle.bold())
                    Text("Use this template for camera, media, photo cleaner, scanner and creative apps.")
                        .foregroundStyle(.secondary)
                }
            }

            benefits
            productCards

            SecondaryButton("Restore Purchases", systemImage: "arrow.clockwise") {
                restore()
            }
            .disabled(isLoading)
        }
    }

    private var benefits: some View {
        VStack(spacing: DesignTokens.Spacing.sm) {
            ForEach(PaywallBenefit.starterDefaults) { benefit in
                AppCard {
                    HStack(spacing: DesignTokens.Spacing.md) {
                        Image(systemName: benefit.systemImage)
                            .frame(width: 28)
                        VStack(alignment: .leading) {
                            Text(benefit.title)
                                .font(.headline)
                            Text(benefit.subtitle)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                }
            }
        }
    }

    private var productCards: some View {
        VStack(spacing: DesignTokens.Spacing.sm) {
            ForEach(products) { product in
                AppCard {
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                        Text(product.title)
                            .font(.title2.bold())
                        Text(product.subtitle)
                            .foregroundStyle(.secondary)
                        PrimaryButton(product.priceText, systemImage: "crown.fill") {
                            purchase(product.id)
                        }
                        .disabled(isLoading)
                    }
                }
            }
        }
    }
}

private struct ComparisonPaywallTemplate: View {
    let products: [PaywallProduct]
    let isLoading: Bool
    let purchase: (String) -> Void
    let restore: () -> Void

    var body: some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            AppCard {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                    Text("Free vs Pro")
                        .font(.largeTitle.bold())
                    comparisonRow("Basic features", free: true, pro: true)
                    comparisonRow("Premium export", free: false, pro: true)
                    comparisonRow("All templates", free: false, pro: true)
                    comparisonRow("Priority updates", free: false, pro: true)
                }
            }

            ForEach(products) { product in
                PrimaryButton("Continue with \(product.title) · \(product.priceText)", systemImage: "checkmark.seal.fill") {
                    purchase(product.id)
                }
                .disabled(isLoading)
            }

            SecondaryButton("Restore Purchases", systemImage: "arrow.clockwise") {
                restore()
            }
            .disabled(isLoading)
        }
    }

    private func comparisonRow(_ title: String, free: Bool, pro: Bool) -> some View {
        HStack {
            Text(title)
            Spacer()
            Image(systemName: free ? "checkmark.circle.fill" : "xmark.circle")
                .foregroundStyle(.secondary)
            Image(systemName: pro ? "checkmark.circle.fill" : "xmark.circle")
        }
        .font(.subheadline)
    }
}
