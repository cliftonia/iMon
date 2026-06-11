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
    /// The single in-flight activity ceremony (feed / clean / heal / refuse).
    var activityTask: Task<Void, Never>?
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
        cancelActivity()
        sleepToggleTask?.cancel()
        sleepToggleTask = nil
        dismissTraining()
        dismissBattle()
    }

    /// Cancels the in-flight ceremony (feed / clean / heal / refuse) and returns
    /// the pet to idle. The single entry point for stopping any activity.
    func cancelActivity() {
        activityTask?.cancel()
        endActivity()
    }

    /// Returns to idle at the natural end of a ceremony (the running task is
    /// finishing on its own, so it isn't cancelled here).
    func endActivity() {
        activityTask = nil
        viewModel.activity = .idle
        feedingAnimator.stop()
        updateAnimation()
    }

    /// Starts the head-shake refusal ceremony (e.g. can't feed / clean / heal).
    func refuse() {
        activityTask?.cancel()
        activityTask = Task { [weak self] in
            await self?.runRefuseSequence()
        }
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

        // Stay awake during an activity, but don't flip the persistent light —
        // otherwise training/battling at night leaves the pet "inside".
        if !wasSleeping, state.isSleeping, viewModel.isBusy {
            state.isSleeping = false
        }

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
        viewModel.dayPhase = DayPhase.resolve(
            isNight: currentlyNight, lightsOn: state.lightsOn
        )
    }

    func updateAnimation() {
        guard viewModel.screenMode == .normal else { return }
        // Only idle and the food-selection menu drive the resting animation;
        // every other activity plays its own ceremony animation.
        switch viewModel.activity {
        case .idle, .feeding(.selecting):
            let kind: SpriteCatalog.AnimationKind =
                state.isSleeping ? .sleep : .idle
            spriteAnimator.play(kind, for: state.species)
        case .feeding(.serving), .feeding(.bite), .feeding(.satisfied),
             .cleaning, .healing, .refusing:
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
