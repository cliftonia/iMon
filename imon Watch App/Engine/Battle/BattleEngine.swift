import Foundation

nonisolated enum RoundOutcome: Equatable, Sendable {
    case playerHit
    case opponentHit
    case clash
}

/// The arena rules: each round is an attack-height duel resolved by the
/// `AttackHeight` triangle, and the session outcome feeds the win/loss record
/// and conditioning that the evolution gates read.
nonisolated enum BattleEngine {

    // MARK: - Query

    static func canBattle(_ state: PetState) -> Bool {
        state.isAwakeAndAlive
    }

    /// Resolves one round by the height triangle. Matching heights are a
    /// `.clash` — nobody is hit; a level session ends in the presenter's
    /// HP tiebreaker instead.
    static func resolveRound(
        playerHeight: AttackHeight,
        opponentHeight: AttackHeight
    ) -> RoundOutcome {
        if playerHeight.beats(opponentHeight) {
            return .playerHit
        }
        if opponentHeight.beats(playerHeight) {
            return .opponentHit
        }
        return .clash
    }

    /// Apply battle result to state, incrementing win/loss counters. Losing
    /// while already weak (low strength or hunger) leaves the pet injured —
    /// a beaten, run-down creature needs medication. Every battle (win or lose)
    /// counts as activity and a win grants +1 trained POW (except for Dotkin).
    static func applyResult(
        _ result: BattleResult,
        to state: PetState,
        at now: Date = .now
    ) -> PetState {
        var state = state
        state.timestamps.lastBattledAt = now
        switch result {
        case .win:
            state.battleWins += 1
            if state.canCondition {
                state.trainedPower = min(
                    TimeConstants.maxConditioning, state.trainedPower + 1
                )
            }
        case .lose:
            state.battleLosses += 1
            let weak = state.strengthHearts.value <= 1 || state.hungerHearts.value <= 1
            if weak {
                state.injure(at: now)
            }
        case .draw:
            break
        }
        return state
    }
}
