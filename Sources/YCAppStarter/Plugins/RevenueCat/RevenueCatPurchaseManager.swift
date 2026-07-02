import Foundation
import Combine
#if canImport(RevenueCat)
import RevenueCat
#endif

@MainActor
final class RevenueCatPurchaseManager: ObservableObject, PurchaseManaging {
    @Published private(set) var entitlement: EntitlementState = .free
    @Published private(set) var products: [PaywallProduct] = []

    private let config: RevenueCatConfig
    private let logger: AppLogging

    #if canImport(RevenueCat)
    private var packagesByProductID: [String: Package] = [:]
    #endif

    init(config: RevenueCatConfig, logger: AppLogging) {
        self.config = config
        self.logger = logger
    }

    func configure() async {
        guard config.isConfigured else {
            logger.warning("RevenueCat is enabled but revenueCatAPIKey is empty. Keeping purchase state in free mode.")
            return
        }

        #if canImport(RevenueCat)
        Purchases.logLevel = config.debugLogsEnabled ? .debug : .info
        Purchases.configure(withAPIKey: config.apiKey)
        await refreshCustomerInfo()
        await loadOfferings()
        #else
        logger.warning("RevenueCat SDK is not linked. Add RevenueCat package dependency or keep NoopPurchaseManager.")
        #endif
    }

    func purchase(productID: String) async throws {
        #if canImport(RevenueCat)
        guard let package = packagesByProductID[productID] else {
            throw PurchaseError.productNotFound(productID)
        }

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            Purchases.shared.purchase(package: package) { [weak self] _, customerInfo, error, userCancelled in
                Task { @MainActor in
                    if userCancelled {
                        continuation.resume(throwing: PurchaseError.cancelled)
                        return
                    }
                    if let error {
                        continuation.resume(throwing: error)
                        return
                    }
                    if let customerInfo {
                        self?.apply(customerInfo: customerInfo)
                    }
                    continuation.resume()
                }
            }
        }
        #else
        throw PurchaseError.providerUnavailable("RevenueCat SDK is not linked.")
        #endif
    }

    func restore() async throws {
        #if canImport(RevenueCat)
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            Purchases.shared.restorePurchases { [weak self] customerInfo, error in
                Task { @MainActor in
                    if let error {
                        continuation.resume(throwing: error)
                        return
                    }
                    if let customerInfo {
                        self?.apply(customerInfo: customerInfo)
                    }
                    continuation.resume()
                }
            }
        }
        #else
        throw PurchaseError.providerUnavailable("RevenueCat SDK is not linked.")
        #endif
    }

    func loadOfferings() async {
        #if canImport(RevenueCat)
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            Purchases.shared.getOfferings { [weak self] offerings, error in
                Task { @MainActor in
                    guard let self else {
                        continuation.resume()
                        return
                    }

                    if let error {
                        self.logger.error("RevenueCat offerings failed: \(error.localizedDescription)")
                        continuation.resume()
                        return
                    }

                    // V2.2 uses RevenueCat's current/default offering by default.
                    // If you need placement-specific or offering-specific selection, add that logic here.
                    let packages = offerings?.current?.availablePackages ?? []
                    var packageMap: [String: Package] = [:]
                    for package in packages {
                        packageMap[package.storeProduct.productIdentifier] = package
                    }
                    self.packagesByProductID = packageMap
                    self.products = packages.map { package in
                        PaywallProduct(
                            id: package.storeProduct.productIdentifier,
                            title: package.storeProduct.localizedTitle,
                            subtitle: package.storeProduct.localizedDescription,
                            priceText: package.storeProduct.localizedPriceString
                        )
                    }
                    continuation.resume()
                }
            }
        }
        #endif
    }

    private func refreshCustomerInfo() async {
        #if canImport(RevenueCat)
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            Purchases.shared.getCustomerInfo { [weak self] customerInfo, error in
                Task { @MainActor in
                    if let error {
                        self?.logger.warning("RevenueCat customer info failed: \(error.localizedDescription)")
                    }
                    if let customerInfo {
                        self?.apply(customerInfo: customerInfo)
                    }
                    continuation.resume()
                }
            }
        }
        #endif
    }

    #if canImport(RevenueCat)
    private func apply(customerInfo: CustomerInfo) {
        let isActive = customerInfo.entitlements[config.entitlementID]?.isActive == true
        entitlement = EntitlementState(
            isPremium: isActive,
            activeEntitlementID: isActive ? config.entitlementID : nil
        )
    }
    #endif
}

enum PurchaseError: LocalizedError {
    case cancelled
    case productNotFound(String)
    case providerUnavailable(String)

    var errorDescription: String? {
        switch self {
        case .cancelled:
            return "Purchase was cancelled."
        case .productNotFound(let id):
            return "Product not found: \(id)"
        case .providerUnavailable(let message):
            return message
        }
    }
}
