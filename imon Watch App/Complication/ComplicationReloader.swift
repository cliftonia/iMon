import Foundation
import WidgetKit

/// Asks WidgetKit to refresh the complication timeline, injected as a witness so
/// callers can be tested with a capturing mock. A no-op when no complication is
/// installed.
nonisolated struct ComplicationReloader: Sendable {
    let reload: @Sendable () -> Void
}

extension ComplicationReloader {
    static let live = ComplicationReloader(
        reload: { WidgetCenter.shared.reloadAllTimelines() }
    )

    // AUDIT 2026-06-24: unused — tests build witnesses inline. Kept as DI scaffolding.
    static let mock = ComplicationReloader(reload: {})
}
