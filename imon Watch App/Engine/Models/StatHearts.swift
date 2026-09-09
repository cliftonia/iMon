import Foundation

/// A heart-meter value that can never go negative. Capacity varies per
/// species and grows on evolution, so the cap is supplied at each
/// `increment(upTo:)` call instead of being frozen into the stored value.
nonisolated struct StatHearts: Codable, Sendable, Hashable {
    /// The current heart count; every mutation clamps it at zero, so it is never negative.
    private(set) var value: Int

    /// Creates a meter with the given value clamped to zero; negative input
    /// becomes empty.
    init(_ value: Int) {
        self.value = max(0, value)
    }

    var isEmpty: Bool { value == 0 }

    /// Raises by one, not exceeding the supplied per-species capacity.
    mutating func increment(upTo max: Int) {
        value = min(max, value + 1)
    }

    /// Lowers by one, never below zero.
    mutating func decrement() {
        value = max(0, value - 1)
    }

    /// The shared zero-heart meter, equal to a meter emptied by repeated decrementing.
    static let empty = StatHearts(0)
}
