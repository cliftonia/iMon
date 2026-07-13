import Foundation

/// Tracks care mistakes when hunger or strength is empty for longer
/// than `careMistakeWindow` (20 min). Uses `pendingCareMistakeAt` to
/// record when the neglect period began.
nonisolated enum CareMistakeTracker {

    static func apply(to state: PetState, at now: Date, bedtime: Bool) -> PetState {
        var state = state
        guard !state.isDead, !state.isEgg else { return state }

        // Light left on past bedtime keeps the pet awake — a care mistake. (Before
        // bedtime the pet is allowed to be up in a lit room, so no penalty.)
        state.careMistakes += accrueMistakes(
            anchor: &state.timestamps.pendingLightsMistakeAt,
            active: bedtime && state.lightsOn,
            window: TimeConstants.lightsMistakeWindow,
            now: now
        )

        // Hunger/strength neglect only applies while awake. Reset the pending
        // clock while asleep so the first waking tick doesn't back-fill the whole
        // night at once (a sparse background wake would otherwise count hours).
        guard !state.isSleeping else {
            state.timestamps.pendingCareMistakeAt = nil
            return state
        }

        let needsAttention = state.hungerHearts.isEmpty || state.strengthHearts.isEmpty
        state.careMistakes += accrueMistakes(
            anchor: &state.timestamps.pendingCareMistakeAt,
            active: needsAttention,
            window: TimeConstants.careMistakeWindow,
            now: now
        )

        return state
    }

    // MARK: - Accrual

    /// Counts one mistake per elapsed `window` since `anchor` while the condition
    /// is active, seeding the anchor on the first active tick and advancing it by
    /// the consumed span. Clears the anchor once the condition lifts.
    private static func accrueMistakes(
        anchor: inout Date?,
        active: Bool,
        window: TimeInterval,
        now: Date
    ) -> Int {
        guard active else {
            anchor = nil
            return 0
        }
        guard let pendingAt = anchor else {
            anchor = now
            return 0
        }

        let mistakes = TickMath.ticks(from: pendingAt, to: now, interval: window)
        if mistakes > 0 {
            anchor = pendingAt.addingTimeInterval(Double(mistakes) * window)
        }
        return mistakes
    }
}
