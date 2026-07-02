import Foundation

public struct StarterWidgetSnapshot: Codable, Hashable, Sendable {
    public var title: String
    public var message: String
    public var progress: Double
    public var updatedAt: Date
    public var deepLinkURLString: String

    public init(
        title: String,
        message: String,
        progress: Double,
        updatedAt: Date = Date(),
        deepLinkURLString: String = "ycappstarter://settings"
    ) {
        self.title = title
        self.message = message
        self.progress = min(max(progress, 0), 1)
        self.updatedAt = updatedAt
        self.deepLinkURLString = deepLinkURLString
    }

    public static let placeholder = StarterWidgetSnapshot(
        title: "YCAppStarter",
        message: "Widget data is ready.",
        progress: 0.42,
        updatedAt: Date(timeIntervalSince1970: 1_735_689_600),
        deepLinkURLString: "ycappstarter://settings"
    )
}

public enum StarterWidgetSharedKeys {
    public static let snapshotKey = "yc.widget.snapshot"
}
