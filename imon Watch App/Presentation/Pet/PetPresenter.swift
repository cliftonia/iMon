import Foundation
import os

final class PetPresenter {

    private(set) var viewModel = PetViewModel()
    let spriteAnimator = SpriteAnimator()
    let feedingAnimator = SpriteAnimator()

    var trainingPresenter: TrainingPresenter?
    var battlePresenter: BattlePresenter?

    var state: PetState
    let store: PetStateStore

    /// Weather-derived night (true/false), or nil when no reading is available.
    private let currentNight: () -> Bool?

    private var gameTimer: Timer?
    var wanderTimer: Timer?
    var feedingTask: Task<Void, Never>?
    var cleaningTask: Task<Void, Never>?
    var healingTask: Task<Void, Never>?
    var refuseTask: Task<Void, Never>?
    var sleepToggleTask: Task<Void, Never>?

    /// Index into the current debug evolution journey (see `+Evolution`).
    var debugStepIndex = 0

    // MARK: - Wander State

    enum WanderState {
        case idle
        case walking(direction: Int, stepsRemaining: Int)
    }

    var wanderState: WanderState = .idle

    // MARK: - Init

    init(
        state: PetState,
        store: PetStateStore,
        currentNight: @escaping () -> Bool? = { nil }
    ) {
        self.state = state
        self.store = store
        self.currentNight = currentNight
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
        startWandering()
    }

    func stopGameLoop() {
        gameTimer?.invalidate()
        gameTimer = nil
        stopWandering()
        cancelFeeding()
        cancelCleaning()
        cancelHealing()
        refuseTask?.cancel()
        refuseTask = nil
        sleepToggleTask?.cancel()
        sleepToggleTask = nil
        dismissTraining()
        dismissBattle()
    }

    private func tick() {
        advanceState()
        checkEvolution()
        save()
    }

    /// Re-applies environment-driven state (e.g. weather day/night) right away,
    /// so the dark screen follows real dusk without waiting for the next tick.
    func environmentDidChange() {
        advanceState()
        save()
    }

    /// The resolved day/night state — weather daylight, or the fixed window.
    var currentlyNight: Bool {
        SleepSchedule.isNight(weatherNight: currentNight(), at: .now)
    }

    private func advanceState() {
        let wasSleeping = state.isSleeping
        state = GameEngine.advance(state, to: .now, isNight: currentNight())

        if !wasSleeping, state.isSleeping, viewModel.isBusy {
            state.isSleeping = false
            state.lightsOn = true
        }

        viewModel.dayPhase = DayPhase.resolve(
            isNight: currentlyNight, lightsOn: state.lightsOn
        )
        updateViewModel()
        updateAnimation()
    }

    // MARK: - Training & Battle Results

    func applyTrainingResult(won: Bool) {
        state = TrainAction.applyResult(to: state, won: won, at: .now)
        if won {
            spriteAnimator.play(.happy, for: state.species)
        }
        updateViewModel()
        save()
    }

    func applyBattleResult(_ result: BattleResult) {
        state = BattleEngine.applyResult(result, to: state)
        updateViewModel()
        save()
    }

    // MARK: - State Access

    func getCurrentState() -> PetState { state }

    // MARK: - Menu Navigation

    func selectNextMenu() {
        let all = PetViewModel.MenuAction.allCases
        let index = (viewModel.menuSelection.rawValue + 1) % all.count
        viewModel.menuSelection = all[index]
    }

    func selectPreviousMenu() {
        let all = PetViewModel.MenuAction.allCases
        let index = (viewModel.menuSelection.rawValue - 1 + all.count) % all.count
        viewModel.menuSelection = all[index]
    }

    // MARK: - Helpers

    func updateViewModel() {
        viewModel.status = PetStatus(from: state)
    }

    func updateAnimation() {
        guard viewModel.screenMode == .normal else { return }
        guard !viewModel.isCleaningAnimation else { return }
        guard !viewModel.isHealingAnimation else { return }
        switch viewModel.feedingPhase {
        case .inactive, .selecting:
            let kind: SpriteCatalog.AnimationKind =
                state.isSleeping ? .sleep : .idle
            spriteAnimator.play(kind, for: state.species)
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
}
