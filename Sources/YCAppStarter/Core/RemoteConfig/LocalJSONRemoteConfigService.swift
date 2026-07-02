import Foundation

@MainActor
final class LocalJSONRemoteConfigService: RemoteConfigServicing {
    private(set) var snapshot: RemoteConfigSnapshot = .empty
    private var overrides: [RemoteConfigKey: RemoteConfigValue] = [:]
    private let bundle: Bundle
    private let resourceName: String
    private let logger: AppLogging

    init(bundle: Bundle = .main, resourceName: String = "RemoteConfigDefaults", logger: AppLogging) {
        self.bundle = bundle
        self.resourceName = resourceName
        self.logger = logger
        loadBundledDefaults()
    }

    func refresh() async {
        loadBundledDefaults()
    }

    func value(for key: RemoteConfigKey) -> RemoteConfigValue? {
        overrides[key] ?? snapshot.values[key]
    }

    func setLocalOverride(_ value: RemoteConfigValue?, for key: RemoteConfigKey) {
        overrides[key] = value
        logger.info("Remote config local override updated: \(key.rawValue)")
    }

    private func loadBundledDefaults() {
        guard let url = bundle.url(forResource: resourceName, withExtension: "json") else {
            snapshot = RemoteConfigSnapshot(
                values: defaultFallbackValues(),
                source: .fallback,
                fetchedAt: Date(),
                lastErrorMessage: "RemoteConfigDefaults.json was not found in the app bundle."
            )
            logger.warning("RemoteConfigDefaults.json was not found. Using in-memory fallback values.")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let rawValues = try JSONDecoder().decode([String: RemoteConfigValue].self, from: data)
            let typedValues = Dictionary(uniqueKeysWithValues: rawValues.map { (RemoteConfigKey(rawValue: $0.key), $0.value) })
            snapshot = RemoteConfigSnapshot(values: typedValues, source: .bundledJSON, fetchedAt: Date(), lastErrorMessage: nil)
            logger.info("Remote config defaults loaded from bundled JSON.")
        } catch {
            snapshot = RemoteConfigSnapshot(
                values: defaultFallbackValues(),
                source: .fallback,
                fetchedAt: Date(),
                lastErrorMessage: error.localizedDescription
            )
            logger.error("Failed to load RemoteConfigDefaults.json: \(error.localizedDescription)")
        }
    }

    private func defaultFallbackValues() -> [RemoteConfigKey: RemoteConfigValue] {
        [
            RemoteConfigKeys.reviewSafeModeEnabled: .bool(false),
            RemoteConfigKeys.featureKillSwitchEnabled: .bool(false),
            RemoteConfigKeys.paywallEnabled: .bool(true),
            RemoteConfigKeys.paywallVariant: .string("minimal"),
            RemoteConfigKeys.adsEnabled: .bool(false),
            RemoteConfigKeys.promotionBannerEnabled: .bool(false),
            RemoteConfigKeys.promotionTitle: .string(""),
            RemoteConfigKeys.promotionMessage: .string(""),
            RemoteConfigKeys.minimumSupportedBuild: .int(0),
            RemoteConfigKeys.maintenanceMessage: .string("")
        ]
    }
}
