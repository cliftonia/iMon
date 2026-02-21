import Foundation

nonisolated struct StatHearts: Codable, Sendable, Hashable {
    private(set) var value: Int

    init(_ value: Int) {
        self.value = max(0, min(4, value))
    }

    var isEmpty: Bool { value == 0 }
    var isFull: Bool { value == 4 }

    mutating func increment() {
        value = min(4, value + 1)
    }

    mutating func decrement() {
        value = max(0, value - 1)
    }

    static let empty = StatHearts(0)
    static let full = StatHearts(4)
}
