import Foundation

// MARK: - Training & Battle Modes

extension PetPresenter {

    // MARK: - Training Mode (Inline)

    func startTrainingMode() {
        guard TrainAction.canTrain(state) else {
            refuse()
            return
        }
        stopWandering()
        let presenter = TrainingPresenter(
            species: state.species
        ) { [weak self] won in
            self?.applyTrainingResult(won: won)
        }
        trainingPresenter = presenter
        viewModel.screenMode = .training
        presenter.startTraining()
    }

    func dismissTraining() {
        trainingPresenter?.cancel()
        trainingPresenter?.spriteAnimator.stop()
        trainingPresenter?.targetAnimator.stop()
        trainingPresenter = nil
        returnToNormalMode()
    }

    // MARK: - Battle Mode (Inline)

    func startBattleMode() {
        guard BattleEngine.canBattle(state) else {
            refuse()
            return
        }
        stopWandering()
        let presenter = BattlePresenter(
            petState: state,
            steps: currentSteps()
        ) { [weak self] result in
            self?.applyBattleResult(result)
        }
        battlePresenter = presenter
        viewModel.screenMode = .battle
        presenter.startBattle()
    }

    func dismissBattle() {
        battlePresenter?.cancelBattle()
        battlePresenter?.petAnimator.stop()
        battlePresenter?.opponentAnimator.stop()
        battlePresenter = nil
        returnToNormalMode()
    }

    /// Shared tail of every mode teardown: back to the home scene, refresh
    /// the animation, and resume wandering.
    private func returnToNormalMode() {
        viewModel.screenMode = .normal
        updateAnimation()
        startWandering()
    }
}
