import Foundation

@MainActor
protocol DeepLinkManaging: AnyObject {
    var lastResult: DeepLinkResult? { get }
    var handledResults: [DeepLinkResult] { get }

    @discardableResult
    func handle(url: URL, source: DeepLinkSource, container: AppContainer) async -> DeepLinkResult
    func route(for url: URL) -> AppRoute?
}
