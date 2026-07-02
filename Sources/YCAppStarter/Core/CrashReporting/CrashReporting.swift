import Foundation

protocol CrashReporting: Sendable {
    func configure()
    func record(error: Error, userInfo: [String: String])
    func log(_ message: String)
    func setUserID(_ userID: String?)
}

extension CrashReporting {
    func record(error: Error) {
        record(error: error, userInfo: [:])
    }
}

struct NoopCrashReporter: CrashReporting {
    func configure() {}
    func record(error: Error, userInfo: [String: String]) {}
    func log(_ message: String) {}
    func setUserID(_ userID: String?) {}
}
