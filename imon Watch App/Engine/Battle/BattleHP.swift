import Foundation

nonisolated enum BattleHP {

    static func calculate(for state: PetState) -> Int {
        let base = state.species.stage.battleHP
        let hungerBonus = state.hungerHearts.value >= 3 ? 1 : 0
        let strengthBonus = state.strengthHearts.value >= 3 ? 1 : 0
        return base + hungerBonus + strengthBonus
    }
}
