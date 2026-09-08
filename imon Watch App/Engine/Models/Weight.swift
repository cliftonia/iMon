import Foundation

/// The pet's weight in grams, kept inside the original device's two-digit
/// range. Every mutation saturates at the bounds, so no sequence of feeds or
/// training can push the value out of displayable range.
nonisolated struct Weight: Codable, Sendable, Hashable {

    static let minGrams = 5
    static let maxGrams = 99

    private(set) var grams: Int

    /// Creates a weight, clamping the given grams into the two-digit range.
    init(_ grams: Int) {
        self.grams = max(Self.minGrams, min(Self.maxGrams, grams))
    }

    var isOverweight: Bool { grams >= Self.maxGrams }

    /// Adds grams, saturating at `maxGrams`.
    mutating func add(_ amount: Int) {
        grams = min(Self.maxGrams, grams + amount)
    }

    /// Subtracts grams, saturating at `minGrams`.
    mutating func subtract(_ amount: Int) {
        grams = max(Self.minGrams, grams - amount)
    }
}
