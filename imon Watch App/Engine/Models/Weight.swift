import Foundation

nonisolated struct Weight: Codable, Sendable, Hashable, Comparable {
    private(set) var grams: Int

    init(_ grams: Int) {
        self.grams = max(5, min(99, grams))
    }

    var isOverweight: Bool { grams >= 99 }

    mutating func add(_ amount: Int) {
        grams = min(99, grams + amount)
    }

    mutating func subtract(_ amount: Int) {
        grams = max(5, grams - amount)
    }

    nonisolated static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.grams < rhs.grams
    }
}
