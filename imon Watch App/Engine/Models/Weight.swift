import Foundation

nonisolated struct Weight: Codable, Sendable, Hashable, Comparable {

    /// The lightest and heaviest a pet can weigh (grams).
    static let minGrams = 5
    static let maxGrams = 99

    private(set) var grams: Int

    init(_ grams: Int) {
        self.grams = max(Self.minGrams, min(Self.maxGrams, grams))
    }

    var isOverweight: Bool { grams >= Self.maxGrams }

    mutating func add(_ amount: Int) {
        grams = min(Self.maxGrams, grams + amount)
    }

    mutating func subtract(_ amount: Int) {
        grams = max(Self.minGrams, grams - amount)
    }

    nonisolated static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.grams < rhs.grams
    }
}
