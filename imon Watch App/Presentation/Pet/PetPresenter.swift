import Foundation
import os

/// Drives the home screen: owns the live `PetState`, the game-tick loop, and
/// the sprite animators, fanning out to the feeding / healing / lights /
/// wander / evolution extensions. Each tick advances the simulation, offers
/// evolutions, and saves; death is edge-triggered inside a tick so `onDeath`
/// fires during play, not on the next launch. Foregrounding restarts the loop
/// and catches the simulation up; backgrounding hands care reminders and the
/// complication timeline to the system (see `handleScenePhase`).
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
    /// Refreshes the watch-face complication.
    let complicationReloader: ComplicationReloader

    /// Weather-derived night (true/false), or nil when no reading is available.
    private let currentNight: () -> Bool?

    /// Today's step count, or nil when unavailable — drives activity-based rates.
    /// Not private: the `+Wander` extension reads it when starting a battle.
    let currentSteps: () -> Int?

    /// The settled total for a past day, so a day that ended while the app was
    /// closed can be credited in full before the accumulator rolls over.
    private let finalSteps: (Date) async -> Int?

    /// Called when the pet dies during play, so the app can show the grave.
    private let onDeath: () -> Void

    private var gameTimer: Timer?
    var wanderTimer: Timer?
    /// The single in-flight activity ceremony (feed / clean / heal / refuse).
    var activityTask: Task<Void, Never>?
    var sleepToggleTask: Task<Void, Never>?
    /// The in-flight settle of a day that ended while the app was closed.
    /// Not private: the tests await it, since the rollover it performs is
    /// asynchronous but must be observed.
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

    /// The resolved day/night state — weather daylight, or the fixed window.
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

    /// Folds today's live step count into the lifetime evolution accumulator,
    /// applying the lazy-day decay on a calendar rollover.
    ///
    /// A day that ends while the app is closed is settled asynchronously first:
    /// HealthKit keeps counting when nothing is watching, so rolling over on
    /// the last figure the app happened to see would both lose that evening's
    /// steps and risk charging a lazy-day penalty to a day that was not lazy.
    private func creditSteps() {
        guard let steps = currentSteps() else { return }
        let progress = StepProgress.Progress(of: state)

        guard let trackedDay = progress.trackedDay,
              !trackedDay.isSameDay(as: .now)
        else {
            rollOver(progress, todaySteps: steps)
            return
        }

        guard dayRecoveryTask == nil else { return }
        dayRecoveryTask = Task { [weak self] in
            await self?.settleAndRollOver(trackedDay: trackedDay, fallbackSteps: steps)
        }
    }

    /// Credits the closed day's true total, then rolls the accumulator over.
    /// Runs even when the tail is unavailable, so a failed lookup delays the
    /// rollover by one fetch rather than stalling it forever.
    private func settleAndRollOver(trackedDay: Date, fallbackSteps: Int) async {
        var progress = StepProgress.Progress(of: state)
        // Settle the closed day *as that day* first: the same-day branch credits
        // the uncounted tail and leaves the true total for the lazy-day verdict.
        if let tail = await finalSteps(trackedDay) {
            progress = StepProgress.advance(
                progress,
                todaySteps: tail,
                now: trackedDay,
                stagePenalty: state.species.stage.lazyDayPenalty
            )
        }
        rollOver(progress, todaySteps: currentSteps() ?? fallbackSteps)
        save()
        dayRecoveryTask = nil
    }

    private func rollOver(_ progress: StepProgress.Progress, todaySteps: Int) {
        StepProgress.advance(
            progress,
            todaySteps: todaySteps,
            now: .now,
            stagePenalty: state.species.stage.lazyDayPenalty
        )
        .write(to: &state)
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

    /// Foregrounding catches the simulation up at once (so returning hours
    /// later doesn't flash a stale scene) and restarts the loop if stopped.
    /// Backgrounding hands care reminders to the system; activation never
    /// cancels them, since a watch flips active on every wrist raise and would
    /// wipe pending notifications before they fire. With the notifications
    /// toggle off, backgrounding instead clears any pending reminders.
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
