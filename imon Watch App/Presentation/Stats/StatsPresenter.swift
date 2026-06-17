import Foundation

final class StatsPresenter {

    private(set) var viewModel = StatsViewModel()

    private static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()

    private static func grouped(_ value: Int) -> String {
        numberFormatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

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
        viewModel.totalSteps = Self.grouped(state.lifetimeActiveSteps)
        let stage = status.species.stage
        if stage == .ultimate {
            viewModel.evolveProgress = "MAX"
        } else {
            let target = Self.grouped(stage.stepsToEvolve)
            viewModel.evolveProgress = viewModel.totalSteps + " / " + target
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
