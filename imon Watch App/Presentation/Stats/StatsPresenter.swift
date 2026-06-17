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
        let hp = BattleHP.calculate(for: state, steps: steps)
        viewModel.hpDisplay = state.trainedHP > 0 ? "\(hp) (+\(state.trainedHP))" : "\(hp)"
        viewModel.powerBonus = "+\(state.trainedPower)"
        if let steps {
            let active = !ActivityModel.isSedentary(steps: steps)
            viewModel.activityLabel = "\(steps) \u{00b7} \(active ? "Active" : "Resting")"
        } else {
            viewModel.activityLabel = "—"
        }
        let total = Self.grouped(state.lifetimeActiveSteps)
        let stage = status.species.stage
        if stage == .ultimate {
            viewModel.evolveProgress = "MAX \u{00b7} " + total
        } else {
            viewModel.evolveProgress = total + " / " + Self.grouped(stage.stepsToEvolve)
        }
        viewModel.battleWins = status.battleWins
        viewModel.battleLosses = status.battleLosses

        let battles = status.battleWins + status.battleLosses
        if battles > 0 {
            let rate = Int(
                Double(status.battleWins) / Double(battles) * 100
            )
            viewModel.winRate = "\(rate)%"
        } else {
            viewModel.winRate = "—"
        }
    }
}
