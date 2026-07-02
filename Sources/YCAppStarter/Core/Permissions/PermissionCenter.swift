import Foundation

enum AppPermission: String, CaseIterable, Identifiable {
    case camera
    case microphone
    case photoLibrary
    case notifications

    var id: String { rawValue }
}

struct PermissionSnapshot: Equatable {
    let permission: AppPermission
    let statusText: String
}

@MainActor
protocol PermissionChecking {
    func snapshot() async -> [PermissionSnapshot]
}

@MainActor
final class PermissionCenter: PermissionChecking {
    func snapshot() async -> [PermissionSnapshot] {
        AppPermission.allCases.map { PermissionSnapshot(permission: $0, statusText: "Not checked") }
    }
}
