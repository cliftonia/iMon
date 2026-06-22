import Foundation
import WatchKit
import os

/// Requests the next background wake-up, injected as a protocol witness so the
/// decision logic is testable even though the OS trigger is not.
nonisolated struct BackgroundRefreshScheduler: Sendable {
    /// Asks the system to wake the app near the given date (one pending at a time).
    let schedule: @Sendable (Date) -> Void
}

extension BackgroundRefreshScheduler {

    static func live() -> BackgroundRefreshScheduler {
        BackgroundRefreshScheduler(
            schedule: { date in
                Task { @MainActor in
                    WKApplication.shared().scheduleBackgroundRefresh(
                        withPreferredDate: date, userInfo: nil
                    ) { error in
                        if let error {
                            Log.presentation.error(
                                "Background refresh schedule failed: \(error.localizedDescription)"
                            )
                        }
                    }
                }
            }
        )
    }

    static let mock = BackgroundRefreshScheduler(schedule: { _ in })
}
