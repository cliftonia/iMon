import Foundation
import WidgetKit

/// Witness that asks WidgetKit to refresh the complication timeline, injected so
/// callers can be tested with a capturing mock. Reloading is a no-op when no
/// complication is installed.
nonisolated struct ComplicationReloader: Sendable {
    let reload: @Sendable () -> Void
}

extension ComplicationReloader {
    static func live() -> ComplicationReloader {
        ComplicationReloader(reload: { WidgetCenter.shared.reloadAllTimelines() })
    }
}
