import Foundation

/// The verdict of a battle: win, lose, or draw.
///
/// A payload-free value type; nonisolated and `Sendable`, so a result crosses
/// isolation boundaries unchanged.
nonisolated enum BattleResult: Sendable {
    case win
    case lose
    case draw
}
