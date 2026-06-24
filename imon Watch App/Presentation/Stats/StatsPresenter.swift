import Foundation

final class StatsPresenter {

    private(set) var viewModel = StatsViewModel()

    // MARK: - Update

    func update(from state: PetState, steps: Int? = nil) {
        let status = PetStatus(from: state)
        viewModel.speciesName = status.species.displayName
        viewModel.stageName = status.stage.displayName
        viewModel.ageDays = status.ageDays
        viewModel.weightGrams = status.weightGrams
        viewModel.hungerHearts = status.hungerHearts.value
        viewModel.maxHunger = status.species.maxHunger
        viewModel.strengthHearts = status.strengthHearts.value
        viewModel.maxStrength = status.species.maxStrength
        let hp = BattleHP.calculate(for: state, steps: steps)
        viewModel.hpDisplay = state.trainedHP > 0 ? "\(hp) (+\(state.trainedHP))" : "\(hp)"
        viewModel.powerBonus = "+\(state.trainedPower)"
        if let steps {
            let active = !ActivityModel.isSedentary(steps: steps)
            viewModel.activityLabel = "\(steps) \u{00b7} \(active ? "Active" : "Resting")"
        } else {
            viewModel.activityLabel = "—"
        }
        let total = StatFormatter.grouped(state.lifetimeActiveSteps)
        if status.species.stage == .ultimate {
            viewModel.evolveProgress = "MAX \u{00b7} " + total
        } else {
            viewModel.evolveProgress = total + " / " + StatFormatter.grouped(state.evolutionGoal)
        }
        viewModel.battleWins = status.battleWins
        viewModel.battleLosses = status.battleLosses

        let battles = status.battleWins + status.battleLosses
        viewModel.winRate = StatFormatter.percent(status.battleWins, of: battles) ?? "—"
    }
}
