import Foundation

nonisolated enum AttackHeight: CaseIterable, Sendable {
    case high, medium, low

    /// The height this one beats — high over medium, medium over low, low
    /// over high. The switch is exhaustive with no `default:` (banned), so
    /// adding a case fails to compile here instead of falling through.
    var prey: AttackHeight {
        switch self {
        case .high: .medium
        case .medium: .low
        case .low: .high
        }
    }

    func beats(_ other: AttackHeight) -> Bool {
        prey == other
    }
}
