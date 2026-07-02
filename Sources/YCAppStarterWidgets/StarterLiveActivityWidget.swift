import ActivityKit
import SwiftUI
import WidgetKit

struct StarterLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: StarterLiveActivityAttributes.self) { context in
            VStack(alignment: .leading, spacing: 8) {
                Text(context.state.title)
                    .font(.headline)
                Text(context.state.message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                ProgressView(value: context.state.progress)
                HStack {
                    Text(context.state.status)
                    Spacer()
                    Text(context.state.updatedAt, style: .time)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .padding()
            .activityBackgroundTint(.clear)
            .widgetURL(URL(string: context.attributes.deepLinkURLString))
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading) {
                        Text(context.state.title)
                            .font(.caption.bold())
                        Text(context.state.status)
                            .font(.caption2)
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("\(Int(context.state.progress * 100))%")
                        .font(.title3.bold())
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(context.state.message)
                            .font(.caption)
                            .lineLimit(1)
                        ProgressView(value: context.state.progress)
                    }
                }
            } compactLeading: {
                Image(systemName: "bolt.fill")
            } compactTrailing: {
                Text("\(Int(context.state.progress * 100))%")
                    .font(.caption2.bold())
            } minimal: {
                Image(systemName: "bolt.fill")
            }
            .widgetURL(URL(string: context.attributes.deepLinkURLString))
        }
    }
}
