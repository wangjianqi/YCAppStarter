import Foundation
import UIKit
#if canImport(UserMessagingPlatform)
import UserMessagingPlatform
#endif

@MainActor
final class GoogleUMPConsentManager: ObservableObject, AdConsentManaging {
    @Published private(set) var canRequestAds: Bool = false
    @Published private(set) var privacyOptionsRequired: Bool = false
    @Published private(set) var statusText: String = "Not requested"
    @Published private(set) var lastErrorMessage: String?

    private let testDeviceIdentifiers: [String]

    init(testDeviceIdentifiers: [String]) {
        self.testDeviceIdentifiers = testDeviceIdentifiers
        refreshCurrentState()
    }

    func requestConsentIfNeeded() async {
#if canImport(UserMessagingPlatform)
        statusText = "Requesting consent info"
        lastErrorMessage = nil

        let parameters = RequestParameters()
        if !testDeviceIdentifiers.isEmpty {
            let debugSettings = DebugSettings()
            debugSettings.testDeviceIdentifiers = testDeviceIdentifiers
            parameters.debugSettings = debugSettings
        }

        await withCheckedContinuation { continuation in
            ConsentInformation.shared.requestConsentInfoUpdate(with: parameters) { [weak self] error in
                Task { @MainActor in
                    if let error {
                        self?.lastErrorMessage = error.localizedDescription
                        self?.statusText = "Consent info update failed"
                        self?.refreshCurrentState()
                        continuation.resume()
                        return
                    }

                    guard let root = RootViewControllerProvider.topMostViewController() else {
                        self?.lastErrorMessage = "Missing root view controller for UMP form."
                        self?.statusText = "Missing presenter"
                        self?.refreshCurrentState()
                        continuation.resume()
                        return
                    }

                    ConsentForm.loadAndPresentIfRequired(from: root) { formError in
                        Task { @MainActor in
                            if let formError {
                                self?.lastErrorMessage = formError.localizedDescription
                                self?.statusText = "Consent form failed"
                            } else {
                                self?.statusText = "Consent flow completed"
                            }
                            self?.refreshCurrentState()
                            continuation.resume()
                        }
                    }
                }
            }
        }
#else
        canRequestAds = false
        privacyOptionsRequired = false
        statusText = "UMP SDK unavailable"
        lastErrorMessage = "UserMessagingPlatform package is not linked."
#endif
    }

    func presentPrivacyOptions() async {
#if canImport(UserMessagingPlatform)
        guard let root = RootViewControllerProvider.topMostViewController() else {
            lastErrorMessage = "Missing root view controller for privacy options."
            return
        }
        await withCheckedContinuation { continuation in
            ConsentForm.presentPrivacyOptionsForm(from: root) { [weak self] error in
                Task { @MainActor in
                    if let error {
                        self?.lastErrorMessage = error.localizedDescription
                        self?.statusText = "Privacy options failed"
                    } else {
                        self?.statusText = "Privacy options presented"
                    }
                    self?.refreshCurrentState()
                    continuation.resume()
                }
            }
        }
#else
        lastErrorMessage = "UserMessagingPlatform package is not linked."
#endif
    }

    func resetForTesting() {
#if canImport(UserMessagingPlatform)
        ConsentInformation.shared.reset()
#endif
        refreshCurrentState()
        statusText = "Consent state reset for testing"
    }

    private func refreshCurrentState() {
#if canImport(UserMessagingPlatform)
        canRequestAds = ConsentInformation.shared.canRequestAds
        privacyOptionsRequired = ConsentInformation.shared.privacyOptionsRequirementStatus == .required
        statusText = statusTextForCurrentConsent()
#else
        canRequestAds = false
        privacyOptionsRequired = false
        statusText = "UMP SDK unavailable"
#endif
    }

#if canImport(UserMessagingPlatform)
    private func statusTextForCurrentConsent() -> String {
        switch ConsentInformation.shared.consentStatus {
        case .notRequired: return "Consent not required"
        case .obtained: return "Consent obtained"
        case .required: return "Consent required"
        case .unknown: return "Consent unknown"
        @unknown default: return "Unknown"
        }
    }
#endif
}
