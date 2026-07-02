import Foundation

@MainActor
protocol WidgetManaging {
    var currentSnapshot: StarterWidgetSnapshot { get }
    func save(snapshot: StarterWidgetSnapshot)
    func reloadAllTimelines()
    func makeSampleSnapshot() -> StarterWidgetSnapshot
}
