import Foundation

@MainActor
final class DeepLinkRouter: DeepLinkManaging, ObservableObject {
    @Published private(set) var lastResult: DeepLinkResult?
    @Published private(set) var handledResults: [DeepLinkResult] = []

    private let logger: AppLogging

    init(logger: AppLogging) {
        self.logger = logger
    }

    @discardableResult
    func handle(url: URL, source: DeepLinkSource, container: AppContainer) async -> DeepLinkResult {
        let policy = container.service(RemoteConfigServicing.self).map(DeepLinkLaunchPolicy.make(from:)) ?? DeepLinkLaunchPolicy(deepLinksEnabled: true, magicLinksEnabled: true)
        guard policy.deepLinksEnabled else {
            return record(url: url, source: source, route: nil, action: "disabled", message: "Deep links are disabled by Remote Config.")
        }

        if isMagicLink(url), policy.magicLinksEnabled {
            do {
                try await container.service(AuthManaging.self)?.handleMagicLinkCallback(url: url)
                let result = record(url: url, source: source, route: .accountCenter, action: "magic-link", message: "Magic link callback handled. Session refresh requested.")
                container.router.push(.accountCenter)
                return result
            } catch {
                return record(url: url, source: source, route: nil, action: "magic-link-error", message: error.localizedDescription)
            }
        }

        if let route = route(for: url) {
            container.router.push(route)
            container.service(PushManaging.self)?.recordOpenedDeepLink(url)
            return record(url: url, source: source, route: route, action: "route", message: "Routed to \(route.id).")
        }

        return record(url: url, source: source, route: nil, action: "ignored", message: "No matching route.")
    }

    func route(for url: URL) -> AppRoute? {
        let parts = normalizedPathComponents(for: url)
        let token = parts.joined(separator: "/").lowercased()

        switch token {
        case "settings": return .settings
        case "paywall", "upgrade": return .paywall
        case "debug": return .debug
        case "profile", "user/profile": return .userProfile
        case "account", "account-center", "account/center": return .accountCenter
        case "privacy", "privacy/requests": return .privacyRequests
        case "privacy/delete-account", "delete-account", "account/delete": return .privacyRequests
        case "push", "push-debug": return .pushDebug
        case "links", "deep-link-debug": return .deepLinkDebug
        case "auth", "auth/callback", "magic-link": return .accountCenter
        default: return nil
        }
    }

    private func record(url: URL, source: DeepLinkSource, route: AppRoute?, action: String, message: String) -> DeepLinkResult {
        let result = DeepLinkResult(url: url, source: source, routeID: route?.id, action: action, message: message)
        lastResult = result
        handledResults.insert(result, at: 0)
        if handledResults.count > 20 { handledResults.removeLast() }
        logger.info("DeepLink: \(message)")
        return result
    }

    private func isMagicLink(_ url: URL) -> Bool {
        let absolute = url.absoluteString.lowercased()
        return absolute.contains("access_token=") || absolute.contains("refresh_token=") || absolute.contains("type=magiclink") || absolute.contains("auth/callback")
    }

    private func normalizedPathComponents(for url: URL) -> [String] {
        var parts: [String] = []
        if let host = url.host, !host.isEmpty { parts.append(host) }
        parts.append(contentsOf: url.pathComponents.filter { $0 != "/" })
        return parts.map { $0.trimmingCharacters(in: CharacterSet(charactersIn: "/")) }.filter { !$0.isEmpty }
    }
}
