import Foundation

/// A heart-meter value that can never go negative. Capacity varies per
/// species and grows on evolution, so the cap is supplied at each
/// `increment(upTo:)` call instead of being frozen into the stored value.
nonisolated struct StatHearts: Codable, Sendable, Hashable {
    private(set) var value: Int

    init(_ value: Int) {
        self.value = max(0, value)
    }

    var isEmpty: Bool { value == 0 }

    /// Raise by one, not exceeding the supplied per-species capacity.
    mutating func increment(upTo max: Int) {
        value = min(max, value + 1)
    }

    mutating func decrement() {
        value = max(0, value - 1)
    }

    static let empty = StatHearts(0)
}
