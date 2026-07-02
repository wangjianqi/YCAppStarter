import Foundation
import WidgetKit

@MainActor
final class AppGroupWidgetStore: WidgetManaging {
    private let appGroupIdentifier: String
    private let logger: AppLogging
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(appGroupIdentifier: String, logger: AppLogging) {
        self.appGroupIdentifier = appGroupIdentifier
        self.logger = logger
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
        seedIfNeeded()
    }

    var currentSnapshot: StarterWidgetSnapshot {
        guard
            let defaults = UserDefaults(suiteName: appGroupIdentifier),
            let data = defaults.data(forKey: StarterWidgetSharedKeys.snapshotKey),
            let snapshot = try? decoder.decode(StarterWidgetSnapshot.self, from: data)
        else {
            return .placeholder
        }
        return snapshot
    }

    func save(snapshot: StarterWidgetSnapshot) {
        guard let defaults = UserDefaults(suiteName: appGroupIdentifier) else {
            logger.warning("App Group is not available: \(appGroupIdentifier)")
            return
        }
        do {
            let data = try encoder.encode(snapshot)
            defaults.set(data, forKey: StarterWidgetSharedKeys.snapshotKey)
            defaults.synchronize()
            logger.info("Saved widget snapshot to App Group: \(appGroupIdentifier)")
        } catch {
            logger.error("Failed to encode widget snapshot: \(error.localizedDescription)")
        }
    }

    func reloadAllTimelines() {
        WidgetCenter.shared.reloadAllTimelines()
        logger.info("Requested WidgetCenter.reloadAllTimelines()")
    }

    func makeSampleSnapshot() -> StarterWidgetSnapshot {
        StarterWidgetSnapshot(
            title: "YCAppStarter V3.1",
            message: "Widget snapshot updated from the main app.",
            progress: Double.random(in: 0.15...0.95),
            updatedAt: Date(),
            deepLinkURLString: "\(StarterSharedConfig.urlScheme)://widget-debug"
        )
    }

    private func seedIfNeeded() {
        guard UserDefaults(suiteName: appGroupIdentifier)?.data(forKey: StarterWidgetSharedKeys.snapshotKey) == nil else { return }
        save(snapshot: .placeholder)
    }
}
