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
        viewModel.battleHP = BattleHP.calculate(for: state, steps: steps)
        if let steps {
            let active = !ActivityModel.isSedentary(steps: steps)
            viewModel.activityLabel = "\(steps) \u{00b7} \(active ? "Active" : "Resting")"
        } else {
            viewModel.activityLabel = "—"
        }
        viewModel.battleWins = status.battleWins
        viewModel.battleLosses = status.battleLosses

        let total = status.battleWins + status.battleLosses
        if total > 0 {
            let rate = Int(
                Double(status.battleWins) / Double(total) * 100
            )
            viewModel.winRate = "\(rate)%"
        } else {
            viewModel.winRate = "N/A"
        }
    }
}
