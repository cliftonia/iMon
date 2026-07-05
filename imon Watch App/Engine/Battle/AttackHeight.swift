import Foundation

nonisolated enum AttackHeight: CaseIterable, Sendable {
    case high, medium, low

    /// RPS triangle: High > Medium > Low > High.
    /// The one height this height beats — keeps `beats` exhaustive
    /// without a banned `default:`.
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
