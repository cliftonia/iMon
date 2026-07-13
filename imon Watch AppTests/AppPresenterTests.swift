import Testing
import Foundation
@testable import imon_Watch_App

@Suite("App lifecycle resolution")
@MainActor
struct AppPresenterTests {

    private struct TestError: Error {}

    /// Captures every store interaction the presenter makes.
    private final class StoreBox: @unchecked Sendable {
        var saved: [PetState] = []
        var deleteCount = 0
    }

    private func makePresenter(
        load: @escaping @Sendable () throws -> PetState?,
        box: StoreBox,
        deleteFails: Bool = false
    ) -> AppPresenter {
        AppPresenter(
            store: PetStateStore(
                save: { box.saved.append($0) },
                load: load,
                delete: {
                    box.deleteCount += 1
                    if deleteFails { throw TestError() }
                }
            ),
            weatherStore: WeatherStore(
                provider: WeatherProvider(fetchCurrent: { throw TestError() })
            ),
            stepActivityStore: StepActivityStore(
                provider: StepCountProvider(fetchTodaySteps: { 0 })
            )
        )
    }

    // MARK: - Load-or-Start-New Resolution

    @Test
    func `a first launch with no saved pet starts hatching`() {
        let presenter = makePresenter(load: { nil }, box: StoreBox())

        presenter.onAppear()

        #expect(presenter.phase == .hatching)
        #expect(presenter.hatchPresenter != nil)
        #expect(presenter.petPresenter == nil)
    }

    @Test
    func `a saved egg re-hatches instead of simulating`() {
        let box = StoreBox()
        var egg = PetState.hatched(at: .now)
        egg.isEgg = true
        let presenter = makePresenter(load: { [egg] in egg }, box: box)

        presenter.onAppear()

        #expect(presenter.phase == .hatching)
        #expect(box.saved.isEmpty)
    }

    @Test
    func `a living pet is caught up, persisted and shown`() throws {
        let hourAgo = Date.now.addingTimeInterval(-3600)
        let saved = makeTestState(at: hourAgo)
        let box = StoreBox()
        let presenter = makePresenter(load: { saved }, box: box)

        presenter.onAppear()

        #expect(presenter.phase == .alive)
        #expect(presenter.petPresenter != nil)
        // The persisted state must be the advanced one, not the raw save.
        let persisted = try #require(box.saved.first)
        #expect(persisted.timestamps.lastAdvancedAt > saved.timestamps.lastAdvancedAt)
    }

    @Test
    func `a pet that died while away shows the grave immediately`() {
        var state = makeTestState()
        state.injuryCount = TimeConstants.maxInjuriesBeforeDeath
        let fatal = state
        let box = StoreBox()
        let presenter = makePresenter(load: { fatal }, box: box)

        presenter.onAppear()

        #expect(presenter.phase == .dead)
        #expect(presenter.deathPresenter != nil)
        #expect(presenter.petPresenter == nil)
        #expect(box.saved.last?.isDead == true)
    }

    @Test
    func `a corrupted save falls back to a fresh hatch`() {
        let presenter = makePresenter(load: { throw TestError() }, box: StoreBox())

        presenter.onAppear()

        #expect(presenter.phase == .hatching)
        #expect(presenter.hatchPresenter != nil)
    }

    // MARK: - Restart After Death

    @Test(arguments: [false, true])
    func `restarting after death deletes the save and hatches anew`(deleteFails: Bool) {
        var state = makeTestState()
        state.isDead = true
        let dead = state
        let box = StoreBox()
        let presenter = makePresenter(load: { dead }, box: box, deleteFails: deleteFails)
        presenter.onAppear()
        #expect(presenter.phase == .dead)

        presenter.deathPresenter?.restartAction()

        #expect(box.deleteCount == 1)
        #expect(presenter.phase == .hatching)
        #expect(presenter.hatchPresenter != nil)
    }
}
