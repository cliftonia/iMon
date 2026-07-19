import Foundation

/// Projects a deterministic timeline of complication snapshots from the saved
/// pet, advancing the engine to each future point so the face shows hunger
/// draining over the next few hours without a live refresh.
nonisolated enum ComplicationTimeline {

    /// `count` is clamped so at least one entry (at `now` itself) is always
    /// produced; each subsequent entry lands `stride` seconds after the last.
    static func entries(
        for state: PetState,
        from now: Date,
        count: Int = 8,
        stride: TimeInterval = 1_800
    ) -> [ComplicationEntry] {
        // A finished pet (dead/egg) has nothing to project — one static entry.
        guard !state.isDead, !state.isEgg else {
            return [ComplicationEntry(date: now, state: state)]
        }

        return (0..<max(1, count)).map { index in
            let date = now.addingTimeInterval(Double(index) * stride)
            let projected = GameEngine.advance(state, to: date)
            return ComplicationEntry(date: date, state: projected)
        }
    }
}
