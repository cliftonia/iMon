import Foundation

nonisolated enum AttackHeight: CaseIterable, Sendable {
    case high, medium, low

    /// RPS triangle: High > Medium > Low > High
    func beats(_ other: AttackHeight) -> Bool {
        switch (self, other) {
        case (.high, .medium), (.medium, .low), (.low, .high):
            true
        default:
            false
        }
    }
}
