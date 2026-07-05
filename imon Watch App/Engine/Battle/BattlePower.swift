import Foundation

nonisolated enum BattlePower {

    /// Calculate effective battle power.
    /// Base power + strength bonus + trained POW. If overweight (99G), halved.
    static func calculate(for state: PetState) -> Double {
        let base = Double(state.species.basePower)
        let strengthBonus = Double(state.strengthHearts.value) * TimeConstants.strengthPowerWeight
        let trainedBonus = Double(state.trainedPower) * TimeConstants.trainedPowerWeight
        let raw = base + strengthBonus + trainedBonus

        if state.weight.isOverweight {
            return raw * TimeConstants.overweightPowerPenalty
        }

        return raw
    }
}
