import Foundation

nonisolated enum RoundOutcome: Equatable, Sendable {
    case playerHit
    case opponentHit
    case clash
}

nonisolated enum BattleEngine {

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
        let threshold = max(finalPet, finalOpponent) * 0.05

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

    /// Apply attribute modifier to base power (+20% advantage).
    static func effectivePower(
        basePower: Double,
        attribute: Attribute,
        against opponentAttribute: Attribute
    ) -> Double {
        if attribute.hasAdvantageOver(opponentAttribute) {
            return basePower * 1.2
        }
        return basePower
    }

    /// Apply battle result to state, incrementing win/loss counters.
    static func applyResult(
        _ result: BattleResult,
        to state: PetState
    ) -> PetState {
        var state = state
        switch result {
        case .win: state.battleWins += 1
        case .lose: state.battleLosses += 1
        case .draw: break
        }
        return state
    }
}
