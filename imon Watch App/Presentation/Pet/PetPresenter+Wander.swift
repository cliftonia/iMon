import Foundation

extension PetPresenter {

    // MARK: - Wandering

    func startWandering() {
        scheduleNextWander()
    }

    func stopWandering() {
        wanderTimer?.invalidate()
        wanderTimer = nil
        wanderState = .idle
        viewModel.petOffsetX = 8
    }

    private var shouldPauseWander: Bool {
        viewModel.isBusy
            || viewModel.screenMode != .normal
            || state.isSleeping
            || state.isDead
    }

    private func scheduleNextWander() {
        wanderTimer?.invalidate()
        let delay = Double.random(in: 3...8)
        wanderTimer = Timer.scheduledTimer(
            withTimeInterval: delay,
            repeats: false
        ) { [weak self] _ in
            Task { @MainActor in
                self?.tryStartWalking()
            }
        }
    }

    private func tryStartWalking() {
        guard !shouldPauseWander else {
            scheduleNextWander()
            return
        }

        // 60% chance to walk, 40% stay idle
        guard Double.random(in: 0...1) < 0.6 else {
            scheduleNextWander()
            return
        }

        let offsetX = viewModel.petOffsetX
        let direction: Int
        if offsetX <= 3 {
            direction = 1
        } else if offsetX >= 8 {
            direction = -1
        } else {
            direction = Bool.random() ? 1 : -1
        }

        let steps = Int.random(in: 3...6)
        wanderState = .walking(
            direction: direction,
            stepsRemaining: steps
        )

        let walk = SpriteCatalog.animation(
            for: state.species, kind: .sideWalk
        )
        spriteAnimator.play(
            direction > 0 ? walk.mirrored() : walk
        )

        wanderTimer = Timer.scheduledTimer(
            withTimeInterval: 0.35,
            repeats: true
        ) { [weak self] _ in
            Task { @MainActor in
                self?.wanderStep()
            }
        }
    }

    private func wanderStep() {
        guard case .walking(
            let direction,
            let remaining
        ) = wanderState else {
            returnToIdle()
            return
        }

        if shouldPauseWander {
            returnToIdle()
            return
        }

        let newX = viewModel.petOffsetX + direction
        guard newX >= 2, newX <= 9, remaining > 0 else {
            returnToIdle()
            return
        }

        viewModel.petOffsetX = newX
        wanderState = .walking(
            direction: direction,
            stepsRemaining: remaining - 1
        )

        if remaining - 1 <= 0 {
            returnToIdle()
        }
    }

    private func returnToIdle() {
        wanderTimer?.invalidate()
        wanderTimer = nil
        wanderState = .idle
        updateAnimation()
        scheduleNextWander()
    }

    // MARK: - Training Mode (Inline)

    func startTrainingMode() {
        guard TrainAction.canTrain(state) else {
            refuseTask?.cancel()
            refuseTask = Task { [weak self] in
                await self?.runRefuseSequence()
            }
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
        trainingPresenter?.spriteAnimator.stop()
        trainingPresenter?.targetAnimator.stop()
        trainingPresenter = nil
        viewModel.screenMode = .normal
        updateAnimation()
        startWandering()
    }

    // MARK: - Battle Mode (Inline)

    func startBattleMode() {
        stopWandering()
        let presenter = BattlePresenter(
            petState: state
        ) { [weak self] result in
            self?.applyBattleResult(result)
        }
        battlePresenter = presenter
        viewModel.screenMode = .battle
        presenter.startBattle()
    }

    func dismissBattle() {
        battlePresenter?.petAnimator.stop()
        battlePresenter?.opponentAnimator.stop()
        battlePresenter = nil
        viewModel.screenMode = .normal
        updateAnimation()
        startWandering()
    }
}
