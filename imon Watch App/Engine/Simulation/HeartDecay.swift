import Foundation

/// Shared heart-depletion arithmetic for the hunger and strength simulators.
/// One heart is lost per elapsed `baseInterval / multiplier` since `anchor`,
/// and the anchor always advances by the full consumed span — even when the
/// hearts are already empty. (Deliberately different from
/// `ConditioningSimulator.decay`, which advances only by points consumed.)
nonisolated enum HeartDecay {

    static func deplete(
        _ hearts: inout StatHearts,
        anchor: inout Date,
        baseInterval: TimeInterval,
        multiplier: Double,
        at now: Date
    ) {
        let interval = baseInterval / multiplier
        let ticks = TickMath.ticks(from: anchor, to: now, interval: interval)
        guard ticks > 0 else { return }

        for _ in 0..<ticks {
            hearts.decrement()
        }

        anchor = anchor.addingTimeInterval(Double(ticks) * interval)
    }
}
