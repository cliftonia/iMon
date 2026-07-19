import Testing
import Foundation
@testable import imon_Watch_App

@Suite("PetPresenter orchestration")
@MainActor
struct PetPresenterTests {

    /// Captures every state the presenter writes back through the store.
    private final class SaveBox: @unchecked Sendable {
        var saved: [PetState] = []
    }

    /// Captures what the presenter hands to the notification scheduler.
    private final class SchedulerBox: @unchecked Sendable {
        var scheduled: [CareNotification]?
        var cancelCount = 0
    }

    private final class CountBox: @unchecked Sendable {
        var count = 0
    }

    private func makePresenter(
        _ state: PetState,
        _ box: SaveBox,
        onDeath: @escaping () -> Void = {},
        scheduler: SchedulerBox = SchedulerBox()
    ) -> PetPresenter {
        let store = PetStateStore(
            save: { box.saved.append($0) }, load: { nil }, delete: {}
        )
        return PetPresenter(
            state: state,
            store: store,
            onDeath: onDeath,
            notificationScheduler: NotificationScheduler(
                schedule: { scheduler.scheduled = $0 },
                notify: { _, _, _ in },
                cancelAll: { scheduler.cancelCount += 1 },
                requestAuthorization: { true }
            ),
            complicationReloader: ComplicationReloader(reload: {})
        )
    }

    @Test
    func `applying a battle win advances state and persists it`() {
        let box = SaveBox()
        var state = makeTestState(species: .emberkin)
        state.battleWins = 2
        let presenter = makePresenter(state, box)

        presenter.applyBattleResult(.win)

        #expect(presenter.getCurrentState().battleWins == 3)
        #expect(box.saved.last?.battleWins == 3)
    }

    @Test
    func `applying a training win builds strength and persists it`() {
        let box = SaveBox()
        let presenter = makePresenter(makeTestState(species: .emberkin, strength: 1), box)

        presenter.applyTrainingResult(won: true)

        let strength = presenter.getCurrentState().strengthHearts.value
        #expect(strength > 1)
        #expect(box.saved.last?.strengthHearts.value == strength)
    }

    // MARK: - Death Edge

    @Test
    func `death during play fires onDeath exactly once and persists the grave`() {
        let box = SaveBox()
        let deaths = CountBox()
        var state = makeTestState()
        state.injuryCount = TimeConstants.maxInjuriesBeforeDeath
        let presenter = makePresenter(state, box, onDeath: { deaths.count += 1 })

        presenter.environmentDidChange()

        #expect(presenter.getCurrentState().isDead)
        #expect(deaths.count == 1)
        #expect(box.saved.last?.isDead == true)

        // Already dead — the edge must not re-fire on the next advance.
        presenter.environmentDidChange()
        #expect(deaths.count == 1)
    }

    // MARK: - Scene Phase

    @Test
    func `backgrounding with notifications on schedules care reminders`() {
        let scheduler = SchedulerBox()
        // A fading pet — the planner drops reminders that land in the night
        // window, so a healthy pet's list is empty when the suite runs in the
        // evening; the fading warning is the one kind that always survives.
        var state = makeTestState()
        state.timestamps.collapsingAt = .now
        let presenter = makePresenter(state, SaveBox(), scheduler: scheduler)

        presenter.handleScenePhase(isActive: false, notificationsEnabled: true)

        #expect(scheduler.scheduled?.isEmpty == false)
        #expect(scheduler.cancelCount == 0)
    }

    @Test
    func `backgrounding with notifications off cancels pending reminders`() {
        let scheduler = SchedulerBox()
        let presenter = makePresenter(makeTestState(), SaveBox(), scheduler: scheduler)

        presenter.handleScenePhase(isActive: false, notificationsEnabled: false)

        #expect(scheduler.scheduled == nil)
        #expect(scheduler.cancelCount == 1)
    }

    @Test
    func `foregrounding catches the simulation up without touching reminders`() {
        let box = SaveBox()
        let scheduler = SchedulerBox()
        let presenter = makePresenter(makeTestState(), box, scheduler: scheduler)

        presenter.handleScenePhase(isActive: true, notificationsEnabled: true)

        #expect(box.saved.isEmpty == false)
        #expect(scheduler.scheduled == nil)
        #expect(scheduler.cancelCount == 0)
        presenter.stopGameLoop()
    }

    // MARK: - Menu Ring

    @Test(arguments: [
        (PetViewModel.MenuAction.stats, PetViewModel.MenuAction.feed),
        (.heal, .settings),
        (.settings, .stats)
    ])
    func `the next-menu ring steps forward and wraps around`(
        from: PetViewModel.MenuAction, expected: PetViewModel.MenuAction
    ) {
        let presenter = makePresenter(makeTestState(), SaveBox())
        presenter.viewModel.menuSelection = from

        presenter.selectNextMenu()

        #expect(presenter.viewModel.menuSelection == expected)
    }

    @Test(arguments: [
        (PetViewModel.MenuAction.stats, PetViewModel.MenuAction.settings),
        (.feed, .stats)
    ])
    func `the previous-menu ring steps back and wraps around`(
        from: PetViewModel.MenuAction, expected: PetViewModel.MenuAction
    ) {
        let presenter = makePresenter(makeTestState(), SaveBox())
        presenter.viewModel.menuSelection = from

        presenter.selectPreviousMenu()

        #expect(presenter.viewModel.menuSelection == expected)
    }

    @Test
    func `crown selection maps onto the ring but is ignored mid-activity`() {
        let presenter = makePresenter(makeTestState(), SaveBox())

        presenter.selectMenu(crownValue: 2)
        #expect(presenter.viewModel.menuSelection == .train)

        presenter.viewModel.activity = .cleaning
        presenter.selectMenu(crownValue: 5)
        #expect(presenter.viewModel.menuSelection == .train)
    }

    // MARK: - Evolution Offer Guards

    /// A pet whose lifetime steps have crossed the current stage's gate.
    private func makeEvolvableState() -> PetState {
        var state = makeTestState(species: .dotkin)
        state.lifetimeActiveSteps = EvolutionStage.fresh.stepsToEvolve
        return state
    }

    @Test
    func `an idle pet past the step gate is offered evolution`() {
        let presenter = makePresenter(makeEvolvableState(), SaveBox())

        presenter.checkEvolution()

        #expect(presenter.viewModel.showEvolution)
        #expect(presenter.viewModel.evolutionTarget == .hopkin)
    }

    @Test
    func `evolution is not offered mid-activity`() {
        let presenter = makePresenter(makeEvolvableState(), SaveBox())
        presenter.viewModel.activity = .cleaning

        presenter.checkEvolution()

        #expect(presenter.viewModel.showEvolution == false)
        #expect(presenter.viewModel.evolutionTarget == nil)
    }

    @Test
    func `an evolution offer already on screen is not overwritten`() {
        let presenter = makePresenter(makeEvolvableState(), SaveBox())
        presenter.viewModel.showEvolution = true

        presenter.checkEvolution()

        // The guard must bail before resolving a new target.
        #expect(presenter.viewModel.evolutionTarget == nil)
    }
}
