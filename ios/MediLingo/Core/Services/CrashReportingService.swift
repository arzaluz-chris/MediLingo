import Foundation
import FirebaseCore

// Firebase Crashlytics bootstrap. FirebaseApp.configure() requires a
// GoogleService-Info.plist in the bundle (human-provided, not committed). When
// it is absent this is a safe no-op, so builds without the plist still run.
enum CrashReportingService {
    static func configureIfPossible() {
        guard FirebaseApp.app() == nil else { return }
        guard Bundle.main.url(forResource: "GoogleService-Info", withExtension: "plist") != nil else { return }
        FirebaseApp.configure()
    }
}
