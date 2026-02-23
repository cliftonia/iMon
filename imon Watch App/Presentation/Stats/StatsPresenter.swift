import Foundation

final class StatsPresenter {

    private(set) var viewModel = StatsViewModel()

    // MARK: - Update

    func update(from state: PetState) {
        let status = PetStatus(from: state)
        viewModel.speciesName = status.species.displayName
        viewModel.stageName = status.stage.displayName
        viewModel.ageDays = status.ageDays
        viewModel.weightGrams = status.weightGrams
        viewModel.hungerHearts = status.hungerHearts.value
        viewModel.strengthHearts = status.strengthHearts.value
        viewModel.battleHP = BattleHP.calculate(for: state)
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
