import Foundation
import os

/// The home screen's presenter: owns the live `PetState`, the tick loop, and
/// the sprite animators, fanning out to the feeding / healing / lights /
/// wander / evolution extensions. Each tick advances the simulation, offers
/// evolutions, and saves; a death inside the tick fires `onDeath` during play.
/// Foregrounding restarts the loop with the catch-up; backgrounding hands
/// care reminders and the complication timeline to the system.
final class PetPresenter {

    private(set) var viewModel = PetViewModel()
    let spriteAnimator = SpriteAnimator()
    let feedingAnimator = SpriteAnimator()

    var trainingPresenter: TrainingPresenter?
    var battlePresenter: BattlePresenter?

    var state: PetState
    let store: PetStateStore

    /// Schedules care reminders while the app is backgrounded.
    let notificationScheduler: NotificationScheduler
    let complicationReloader: ComplicationReloader

    /// Weather-derived night (true/false), or nil when no reading is available.
    private let currentNight: () -> Bool?

    /// Today's step count, or nil when unavailable — drives activity scaling.
    /// Not private: the `+Wander` extension reads it when starting a battle.
    let currentSteps: () -> Int?

    /// The final step total for a finished day, or nil when unavailable — a
    /// day that ended while the app was closed is credited in full at rollover.
    /// Not private: the `+Steps` extension performs the rollover.
    let finalSteps: (Date) async -> Int?

    /// Called when the pet dies during play, so the app can show the grave.
    private let onDeath: () -> Void

    private var gameTimer: Timer?
    var wanderTimer: Timer?
    /// The single in-flight activity ceremony (feed / clean / heal / refuse).
    var activityTask: Task<Void, Never>?
    var sleepToggleTask: Task<Void, Never>?
    /// The in-flight rollover of a day that ended while the app was closed.
    /// Not private: the tests await it, since the rollover is asynchronous but
    /// must be observed.
    var dayRecoveryTask: Task<Void, Never>?

    #if DEBUG
    /// Index into the current debug evolution journey (see `+Evolution`).
    var debugStepIndex = 0
    #endif

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
        currentNight: @escaping () -> Bool? = { nil },
        currentSteps: @escaping () -> Int? = { nil },
        finalSteps: @escaping (Date) async -> Int? = { _ in nil },
        onDeath: @escaping () -> Void = {},
        notificationScheduler: NotificationScheduler = .live(),
        complicationReloader: ComplicationReloader = .live()
    ) {
        self.state = state
        self.store = store
        self.currentNight = currentNight
        self.currentSteps = currentSteps
        self.finalSteps = finalSteps
        self.onDeath = onDeath
        self.notificationScheduler = notificationScheduler
        self.complicationReloader = complicationReloader
        updateViewModel()
    }

    // MARK: - Game Loop

    func startGameLoop() {
        // Idempotent — a re-fired `.task` would otherwise double-tick and double-save.
        guard gameTimer == nil else { return }
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
        cancelActivity()
        sleepToggleTask?.cancel()
        sleepToggleTask = nil
        // Left running, it would save a pet the app has already discarded.
        dayRecoveryTask?.cancel()
        dayRecoveryTask = nil
        // Mode teardown resumes wandering, so the wander stop must come last —
        // otherwise a hidden screen keeps walking its pet and redrawing.
        dismissTraining()
        dismissBattle()
        stopWandering()
        spriteAnimator.stop()
        feedingAnimator.stop()
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

    /// Cancels any in-flight ceremony and starts a new one. The single entry
    /// point for starting an activity — enforces the one-in-flight invariant.
    func startActivity(_ sequence: @escaping (PetPresenter) async -> Void) {
        activityTask?.cancel()
        activityTask = Task { [weak self] in
            guard let self else { return }
            await sequence(self)
        }
    }

    /// Starts the head-shake refusal ceremony (e.g. can't feed / clean / heal).
    func refuse() {
        startActivity { await $0.runRefuseSequence() }
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

    // MARK: - Care Notifications

    /// Schedules the care reminders for the current state — called when the app
    /// backgrounds, since notifications only matter while the owner is away.
    func scheduleCareNotifications(now: Date = .now) {
        let plan = CareNotificationPlanner.plan(
            for: state, now: now, steps: currentSteps()
        )
        notificationScheduler.schedule(plan)
        // Bake a fresh complication timeline — backgrounding is its last chance.
        ComplicationStore.save(ComplicationTimeline.entries(for: state, from: now))
        complicationReloader.reload()
    }

    /// Clears any pending reminders — used when the player switches notifications
    /// off, so stale ones don't keep firing.
    func cancelCareNotifications() {
        notificationScheduler.cancelAll()
    }

    /// The resolved night signal — the weather's daylight flag, else the fixed
    /// clock window.
    var currentlyNight: Bool {
        SleepSchedule.isNight(weatherNight: currentNight(), at: .now)
    }

    private func advanceState() {
        let wasSleeping = state.isSleeping
        let wasDead = state.isDead
        state = GameEngine.advance(
            state, to: .now, isNight: currentNight(), steps: currentSteps()
        )
        creditSteps()

        // Don't flip the persistent light — night training would leave the pet "inside".
        if !wasSleeping, state.isSleeping, viewModel.isBusy {
            state.isSleeping = false
        }

        updateViewModel()
        updateAnimation()

        // Surface a natural death right away (not just on next launch).
        if !wasDead, state.isDead {
            onDeath()
        }
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
        state = BattleEngine.applyResult(result, to: state, at: .now)
        updateViewModel()
        save()
    }

    // MARK: - State Access

    func getCurrentState() -> PetState { state }

    // MARK: - Menu Navigation

    /// Crown rotation maps straight onto the menu ring (ignored mid-activity).
    func selectMenu(crownValue: Double) {
        guard !viewModel.isBusy else { return }
        let all = PetViewModel.MenuAction.allCases
        let index = Int(crownValue.rounded()) % all.count
        viewModel.menuSelection = all[index]
    }

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

    // MARK: - Scene Phase

    /// Foregrounding runs the catch-up at once (no stale scene after hours away)
    /// and restarts the loop if stopped; backgrounding hands care reminders to
    /// the system — or clears them when the toggle is off. Activation never
    /// cancels: a wrist raise flips active and would wipe them before they fire.
    func handleScenePhase(isActive: Bool, notificationsEnabled: Bool) {
        if isActive {
            startGameLoop()
            environmentDidChange()
        } else if notificationsEnabled {
            scheduleCareNotifications()
        } else {
            cancelCareNotifications()
        }
    }

    // MARK: - Helpers

    func updateViewModel() {
        viewModel.status = PetStatus(from: state)
        viewModel.evolutionProgress = state.evolutionProgressFraction
        viewModel.dayPhase = DayPhase.resolve(
            isNight: currentlyNight, lightsOn: state.lightsOn
        )
    }

    func updateAnimation() {
        guard viewModel.screenMode == .normal else { return }
        // Every other activity plays its own ceremony animation — never override it.
        switch viewModel.activity {
        case .idle, .feeding(.selecting):
            if state.isLanguishing, !state.isSleeping {
                // Languishing droops only awake — asleep it still rests, like the toy.
                spriteAnimator.play(SpriteCatalog.weakAnimation(for: state.species))
            } else {
                let kind: SpriteCatalog.AnimationKind =
                    state.isSleeping ? .sleep : .idle
                spriteAnimator.play(kind, for: state.species)
            }
        case .feeding(.serving), .feeding(.bite), .feeding(.satisfied),
             .cleaning, .healing, .refusing, .evolving:
            // The evolution flash keeps whatever sprite is on screen; the strobe
            // washes it, and the reveal plays its own happy bounce.
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
