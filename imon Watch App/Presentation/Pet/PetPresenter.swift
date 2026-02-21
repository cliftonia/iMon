import Foundation
import os
import WatchKit

final class PetPresenter {

    private(set) var viewModel = PetViewModel()
    let spriteAnimator = SpriteAnimator()
    let feedingAnimator = SpriteAnimator()

    private(set) var trainingPresenter: TrainingPresenter?
    private(set) var battlePresenter: BattlePresenter?

    var state: PetState
    let store: PetStateStore
    private var gameTimer: Timer?
    var feedingTask: Task<Void, Never>?
    var cleaningTask: Task<Void, Never>?

    // MARK: - Init

    init(state: PetState, store: PetStateStore) {
        self.state = state
        self.store = store
        updateViewModel()
    }

    // MARK: - Game Loop

    func startGameLoop() {
        advanceState()
        gameTimer = Timer.scheduledTimer(
            withTimeInterval: TimeConstants.gameTickInterval,
            repeats: true
        ) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }
    }

    func stopGameLoop() {
        gameTimer?.invalidate()
        gameTimer = nil
        cancelFeeding()
        cancelCleaning()
        dismissTraining()
        dismissBattle()
    }

    private func tick() {
        advanceState()
        checkEvolution()
        save()
    }

    private func advanceState() {
        let wasSleeping = state.isSleeping
        state = GameEngine.advance(state, to: .now)

        if viewModel.isBusy, !wasSleeping, state.isSleeping {
            state.isSleeping = false
            state.lightsOn = true
        }

        updateViewModel()
        updateAnimation()
    }

    // MARK: - Heal

    func healAction() {
        guard HealAction.canHeal(state) else {
            WKInterfaceDevice.rejectHaptic()
            return
        }
        state = HealAction.apply(to: state, at: .now)
        updateViewModel()
        save()
    }

    // MARK: - Lights

    func lightsAction() {
        guard LightsAction.canToggle(state) else {
            WKInterfaceDevice.rejectHaptic()
            return
        }
        state = LightsAction.apply(to: state)
        updateViewModel()
        save()
    }

    // MARK: - Training Result

    func applyTrainingResult(won: Bool) {
        state = TrainAction.applyResult(
            to: state, won: won, at: .now
        )
        if won {
            spriteAnimator.play(
                SpriteCatalog.animation(
                    for: state.species, kind: .happy
                )
            )
        }
        updateViewModel()
        save()
    }

    // MARK: - Battle Result

    func applyBattleResult(_ result: BattleResult) {
        state = BattleEngine.applyResult(result, to: state)
        updateViewModel()
        save()
    }

    // MARK: - State Access

    func getCurrentState() -> PetState { state }

    // MARK: - Evolution

    private func checkEvolution() {
        guard let target = EvolutionEngine.checkEvolution(
            for: state, at: .now
        ) else {
            return
        }
        viewModel.showEvolution = true
        viewModel.evolutionTarget = target
    }

    func applyEvolution() {
        guard let target = viewModel.evolutionTarget else {
            return
        }
        state = EvolutionEngine.evolve(
            state, to: target, at: .now
        )
        viewModel.showEvolution = false
        viewModel.evolutionTarget = nil
        updateViewModel()
        updateAnimation()
        save()
        WKInterfaceDevice.evolveHaptic()
    }

    // MARK: - Menu Navigation

    func selectNextMenu() {
        let all = PetViewModel.MenuAction.allCases
        let index = (viewModel.menuSelection.rawValue + 1)
            % all.count
        viewModel.menuSelection = all[index]
    }

    func selectPreviousMenu() {
        let all = PetViewModel.MenuAction.allCases
        let index = (viewModel.menuSelection.rawValue - 1
            + all.count) % all.count
        viewModel.menuSelection = all[index]
    }

    // MARK: - Helpers

    func updateViewModel() {
        viewModel.status = PetStatus(from: state)
    }

    func updateAnimation() {
        guard viewModel.screenMode == .normal else { return }
        guard !viewModel.isCleaningAnimation else { return }
        switch viewModel.feedingPhase {
        case .inactive, .selecting:
            let kind: SpriteCatalog.AnimationKind =
                state.isSleeping ? .sleep : .idle
            spriteAnimator.play(
                SpriteCatalog.animation(
                    for: state.species, kind: kind
                )
            )
        case .serving, .bite, .satisfied:
            break
        }
    }

    func save() {
        do {
            try store.save(state)
        } catch {
            Log.presentation.error(
                "Failed to save: \(error.localizedDescription)"
            )
        }
    }

    // MARK: - Training Mode (Inline)

    func startTrainingMode() {
        guard TrainAction.canTrain(state) else {
            WKInterfaceDevice.rejectHaptic()
            return
        }
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
    }

    // MARK: - Battle Mode (Inline)

    func startBattleMode() {
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
    }
}
