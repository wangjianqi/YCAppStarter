import Foundation
import FirebaseRemoteConfig

@MainActor
final class FirebaseRemoteConfigService: RemoteConfigServicing {
    private(set) var snapshot: RemoteConfigSnapshot
    private let fallback: LocalJSONRemoteConfigService
    private let remoteConfig: RemoteConfig
    private let logger: AppLogging

    init(fallback: LocalJSONRemoteConfigService, logger: AppLogging, minimumFetchInterval: TimeInterval = 3600) {
        self.fallback = fallback
        self.snapshot = fallback.snapshot
        self.remoteConfig = RemoteConfig.remoteConfig()
        self.logger = logger

        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = minimumFetchInterval
        remoteConfig.configSettings = settings
        remoteConfig.setDefaults(fallback.snapshot.firebaseDefaultValues())
    }

    func refresh() async {
        do {
            try await fetchAndActivate()
            var values = fallback.snapshot.values
            for key in RemoteConfigKeys.launchCriticalKeys {
                let remoteValue = remoteConfig.configValue(forKey: key.rawValue)
                if let converted = RemoteConfigValue(remoteValue: remoteValue) {
                    values[key] = converted
                }
            }
            snapshot = RemoteConfigSnapshot(values: values, source: .firebase, fetchedAt: Date(), lastErrorMessage: nil)
            logger.info("Firebase Remote Config refreshed.")
        } catch {
            snapshot = RemoteConfigSnapshot(
                values: fallback.snapshot.values,
                source: .bundledJSON,
                fetchedAt: fallback.snapshot.fetchedAt,
                lastErrorMessage: error.localizedDescription
            )
            logger.warning("Firebase Remote Config refresh failed. Using bundled fallback: \(error.localizedDescription)")
        }
    }

    func value(for key: RemoteConfigKey) -> RemoteConfigValue? {
        snapshot.values[key] ?? fallback.value(for: key)
    }

    func setLocalOverride(_ value: RemoteConfigValue?, for key: RemoteConfigKey) {
        fallback.setLocalOverride(value, for: key)
    }

    private func fetchAndActivate() async throws {
        try await withCheckedThrowingContinuation { continuation in
            remoteConfig.fetchAndActivate { _, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
}

private extension RemoteConfigValue {
    init?(remoteValue: FirebaseRemoteConfig.RemoteConfigValue) {
        let stringValue = remoteValue.stringValue ?? ""
        if let boolValue = stringValue.asRemoteConfigBool {
            self = .bool(boolValue)
        } else if let intValue = Int(stringValue) {
            self = .int(intValue)
        } else if let doubleValue = Double(stringValue) {
            self = .double(doubleValue)
        } else {
            self = .string(stringValue)
        }
    }
}

private extension String {
    var asRemoteConfigBool: Bool? {
        switch trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
        case "true", "1", "yes", "on": return true
        case "false", "0", "no", "off": return false
        default: return nil
        }
    }
}

private extension RemoteConfigSnapshot {
    func firebaseDefaultValues() -> [String: NSObject] {
        Dictionary(uniqueKeysWithValues: values.map { key, value in
            (key.rawValue, value.firebaseObjectValue)
        })
    }
}

private extension RemoteConfigValue {
    var firebaseObjectValue: NSObject {
        switch self {
        case .bool(let value): return NSNumber(value: value)
        case .string(let value): return NSString(string: value)
        case .int(let value): return NSNumber(value: value)
        case .double(let value): return NSNumber(value: value)
        }
    }
}
