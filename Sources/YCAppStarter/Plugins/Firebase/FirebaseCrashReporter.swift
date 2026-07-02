import Foundation
#if canImport(FirebaseCrashlytics)
import FirebaseCrashlytics
#endif

struct FirebaseCrashReporter: CrashReporting {
    func configure() {}

    func record(error: Error, userInfo: [String: String]) {
        #if canImport(FirebaseCrashlytics)
        let nsError = error as NSError
        Crashlytics.crashlytics().record(error: nsError, userInfo: userInfo.mapValues { $0 as Any })
        #endif
    }

    func log(_ message: String) {
        #if canImport(FirebaseCrashlytics)
        Crashlytics.crashlytics().log(message)
        #endif
    }

    func setUserID(_ userID: String?) {
        #if canImport(FirebaseCrashlytics)
        Crashlytics.crashlytics().setUserID(userID ?? "")
        #endif
    }
}
