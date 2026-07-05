import Foundation

nonisolated enum RoundOutcome: Equatable, Sendable {
    case playerHit
    case opponentHit
    case clash
}

nonisolated enum BattleEngine {

    // MARK: - Query

    static func canBattle(_ state: PetState) -> Bool {
        !state.isDead && !state.isEgg && !state.isSleeping
    }

    // AUDIT 2026-06-24: unused in production — live battles use the interactive
    // `resolveRound` (height-based). This full-auto resolver (and `effectivePower`
    // + the attribute-advantage triangle it relies on) is exercised only by tests.
    // Keep for a future auto-battle mode, or remove with its tests.
    /// Run a battle between pet and opponent.
    /// Applies attribute advantages and RNG variance to determine outcome.
    static func battle(
        petState: PetState,
        opponent: BattleOpponent
    ) -> BattleResult {
        let petPower = BattlePower.calculate(for: petState)
        let effectivePet = effectivePower(
            basePower: petPower,
            attribute: petState.species.attribute,
            against: opponent.attribute
        )
        let effectiveOpp = effectivePower(
            basePower: opponent.power,
            attribute: opponent.attribute,
            against: petState.species.attribute
        )

        let variance = TimeConstants.battleRNGVariance
        let petRNG = Double.random(in: (1 - variance)...(1 + variance))
        let opponentRNG = Double.random(in: (1 - variance)...(1 + variance))

        let finalPet = effectivePet * petRNG
        let finalOpponent = effectiveOpp * opponentRNG

        let difference = abs(finalPet - finalOpponent)
        let threshold = max(finalPet, finalOpponent) * TimeConstants.battleDrawThreshold

        if difference < threshold { return .draw }
        return finalPet > finalOpponent ? .win : .lose
    }

    /// Resolve a single interactive round based on attack heights.
    /// Height advantage wins; same height uses power tiebreak.
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

    // AUDIT 2026-06-24: reachable only via the unused `battle()` above + tests.
    /// Apply attribute modifier to base power (+20% advantage).
    static func effectivePower(
        basePower: Double,
        attribute: Attribute,
        against opponentAttribute: Attribute
    ) -> Double {
        if attribute.hasAdvantageOver(opponentAttribute) {
            return basePower * TimeConstants.attributeAdvantageMultiplier
        }
        return basePower
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
            if weak, !state.isInjured {
                state.isInjured = true
                state.timestamps.injuredAt = now
                state.injuryCount += 1
            }
        case .draw:
            break
        }
        return state
    }
}
