import Foundation

/// Shared heart-depletion arithmetic for the hunger and strength simulators.
/// One heart is lost per elapsed `baseInterval / multiplier` since `anchor`,
/// and the anchor always advances by the full consumed span — even when the
/// hearts are already empty. (Deliberately different from
/// `ConditioningSimulator.decay`, which advances only by points consumed.)
nonisolated enum HeartDecay {

    /// Returns the moment the last heart was spent, or nil if the stat did not
    /// run out during this call. The anchor keeps advancing past empty, so this
    /// is the only chance to learn when empty began.
    @discardableResult
    static func deplete(
        _ hearts: inout StatHearts,
        anchor: inout Date,
        baseInterval: TimeInterval,
        multiplier: Double,
        at now: Date
    ) -> Date? {
        let interval = baseInterval / multiplier
        let ticks = TickMath.ticks(from: anchor, to: now, interval: interval)
        guard ticks > 0 else { return nil }

        let start = anchor
        let ticksToEmpty = hearts.value
        for _ in 0..<ticks {
            hearts.decrement()
        }

        anchor = anchor.addingTimeInterval(Double(ticks) * interval)

        guard ticksToEmpty > 0, ticks >= ticksToEmpty else { return nil }
        return start.addingTimeInterval(Double(ticksToEmpty) * interval)
    }
}
