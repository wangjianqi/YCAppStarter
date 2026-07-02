import SwiftUI
import WidgetKit

struct StarterStatusEntry: TimelineEntry {
    let date: Date
    let snapshot: StarterWidgetSnapshot
}

struct StarterStatusProvider: TimelineProvider {
    func placeholder(in context: Context) -> StarterStatusEntry {
        StarterStatusEntry(date: Date(), snapshot: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (StarterStatusEntry) -> Void) {
        completion(StarterStatusEntry(date: Date(), snapshot: loadSnapshot()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StarterStatusEntry>) -> Void) {
        let snapshot = loadSnapshot()
        let entry = StarterStatusEntry(date: Date(), snapshot: snapshot)
        let next = Calendar.current.date(byAdding: .minute, value: 60, to: Date()) ?? Date().addingTimeInterval(3600)
        completion(Timeline(entries: [entry], policy: .after(next)))
    }

    private func loadSnapshot() -> StarterWidgetSnapshot {
        guard
            let defaults = UserDefaults(suiteName: StarterSharedConfig.appGroupIdentifier),
            let data = defaults.data(forKey: StarterWidgetSharedKeys.snapshotKey)
        else { return .placeholder }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return (try? decoder.decode(StarterWidgetSnapshot.self, from: data)) ?? .placeholder
    }
}

struct StarterStatusWidgetEntryView: View {
    let entry: StarterStatusEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(entry.snapshot.title)
                .font(.headline)
            Text(entry.snapshot.message)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(3)
            ProgressView(value: entry.snapshot.progress)
            Text(entry.snapshot.updatedAt, style: .time)
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .containerBackground(.fill.tertiary, for: .widget)
        .widgetURL(URL(string: entry.snapshot.deepLinkURLString.replacingOccurrences(of: "ycappstarter", with: StarterSharedConfig.urlScheme, options: [.anchored])))
    }
}

struct StarterStatusWidget: Widget {
    let kind = "YCAppStarterStatusWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StarterStatusProvider()) { entry in
            StarterStatusWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Starter Status")
        .description("Shows the latest App Group snapshot from the main app.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular, .accessoryRectangular])
    }
}
