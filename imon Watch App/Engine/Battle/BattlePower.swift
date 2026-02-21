import Foundation

nonisolated enum BattlePower {

    /// Calculate effective battle power.
    /// Base power + strength bonus. If overweight (99G), power is halved.
    static func calculate(for state: PetState) -> Double {
        let base = Double(state.species.basePower)
        let strengthBonus = Double(state.strengthHearts.value) * 5.0
        let raw = base + strengthBonus

        if state.weight.isOverweight {
            return raw * 0.5
        }

        return raw
    }
}
