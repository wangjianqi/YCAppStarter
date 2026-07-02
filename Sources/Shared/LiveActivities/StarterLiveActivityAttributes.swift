import ActivityKit
import Foundation

public struct StarterLiveActivityAttributes: ActivityAttributes, Hashable {
    public struct ContentState: Codable, Hashable {
        public var title: String
        public var message: String
        public var progress: Double
        public var status: String
        public var updatedAt: Date

        public init(title: String, message: String, progress: Double, status: String, updatedAt: Date = Date()) {
            self.title = title
            self.message = message
            self.progress = min(max(progress, 0), 1)
            self.status = status
            self.updatedAt = updatedAt
        }

        public static let sample = ContentState(
            title: "Launch Kit",
            message: "Live Activity running",
            progress: 0.35,
            status: "Active"
        )
    }

    public var activityID: String
    public var deepLinkURLString: String

    public init(activityID: String, deepLinkURLString: String = "ycappstarter://settings") {
        self.activityID = activityID
        self.deepLinkURLString = deepLinkURLString
    }
}
