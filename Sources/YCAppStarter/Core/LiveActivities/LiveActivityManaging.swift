import Foundation

@MainActor
protocol LiveActivityManaging {
    var activeSnapshots: [LiveActivitySnapshot] { get }
    func startSampleActivity(pushTypeToken: Bool) async throws
    func updateSampleActivity(progress: Double) async
    func endAllActivities() async
}
