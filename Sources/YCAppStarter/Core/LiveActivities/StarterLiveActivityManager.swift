import ActivityKit
import Foundation

@MainActor
final class StarterLiveActivityManager: LiveActivityManaging {
    private let logger: AppLogging

    init(logger: AppLogging) {
        self.logger = logger
    }

    var activeSnapshots: [LiveActivitySnapshot] {
        Activity<StarterLiveActivityAttributes>.activities.map { activity in
            let state = activity.content.state
            return LiveActivitySnapshot(
                id: activity.id,
                title: state.title,
                status: activity.activityState.debugDescription,
                progress: state.progress,
                updatedAt: state.updatedAt
            )
        }
    }

    func startSampleActivity(pushTypeToken: Bool) async throws {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            throw LiveActivityError.activitiesDisabled
        }

        let attributes = StarterLiveActivityAttributes(activityID: UUID().uuidString)
        let state = StarterLiveActivityAttributes.ContentState(
            title: "YCAppStarter",
            message: "Sample Live Activity started.",
            progress: 0.1,
            status: "Starting"
        )
        let content = ActivityContent(state: state, staleDate: Date().addingTimeInterval(60 * 30))
        let pushType: PushType? = pushTypeToken ? .token : nil
        _ = try Activity.request(attributes: attributes, content: content, pushType: pushType)
        logger.info("Started sample Live Activity")
    }

    func updateSampleActivity(progress: Double) async {
        let bounded = min(max(progress, 0), 1)
        for activity in Activity<StarterLiveActivityAttributes>.activities {
            let state = StarterLiveActivityAttributes.ContentState(
                title: "YCAppStarter",
                message: "Sample Live Activity updated from the app.",
                progress: bounded,
                status: bounded >= 1 ? "Complete" : "Running"
            )
            await activity.update(ActivityContent(state: state, staleDate: Date().addingTimeInterval(60 * 30)))
        }
        logger.info("Updated sample Live Activities to \(Int(bounded * 100))%")
    }

    func endAllActivities() async {
        for activity in Activity<StarterLiveActivityAttributes>.activities {
            let state = StarterLiveActivityAttributes.ContentState(
                title: "YCAppStarter",
                message: "Sample Live Activity ended.",
                progress: 1,
                status: "Ended"
            )
            await activity.end(ActivityContent(state: state, staleDate: nil), dismissalPolicy: .immediate)
        }
        logger.info("Ended all sample Live Activities")
    }
}

enum LiveActivityError: LocalizedError {
    case activitiesDisabled

    var errorDescription: String? {
        switch self {
        case .activitiesDisabled:
            return "Live Activities are disabled on this device or for this app."
        }
    }
}

private extension ActivityState {
    var debugDescription: String {
        switch self {
        case .active: return "Active"
        case .dismissed: return "Dismissed"
        case .ended: return "Ended"
        case .stale: return "Stale"
        @unknown default: return "Unknown"
        }
    }
}
