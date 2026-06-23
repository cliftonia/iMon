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

    private func makePresenter(_ state: PetState, _ box: SaveBox) -> PetPresenter {
        let store = PetStateStore(
            save: { box.saved.append($0) }, load: { nil }, delete: {}
        )
        return PetPresenter(state: state, store: store)
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
}
