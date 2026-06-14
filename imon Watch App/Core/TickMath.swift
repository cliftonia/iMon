import Foundation

/// Safe whole-interval arithmetic for the time-based simulators.
nonisolated enum TickMath {

    /// The number of whole `interval`s between `start` and `now`, clamped to a
    /// safe `Int`. Guards against non-finite or negative spans (a backward
    /// clock) and against 32-bit overflow — on watchOS (`arm64_32`) `Int` is
    /// 32-bit, so a bare `Int(largeDouble)` can trap on device.
    static func ticks(
        from start: Date,
        to now: Date,
        interval: TimeInterval
    ) -> Int {
        guard interval > 0 else { return 0 }
        let elapsed = now.timeIntervalSince(start)
        guard elapsed.isFinite, elapsed > 0 else { return 0 }
        let count = (elapsed / interval).rounded(.down)
        guard count >= 1 else { return 0 }
        return count >= Double(Int.max) ? Int.max : Int(count)
    }
}
