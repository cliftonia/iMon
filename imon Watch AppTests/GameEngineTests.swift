import Testing
import Foundation
@testable import imon_Watch_App

@Suite("GameEngine")
struct GameEngineTests {

    @Test
    func `advance updates age in days`() {
        let start = Date.now.addingTimeInterval(-86400 * 3)
        var state = makeTestState(at: start)
        state.bornAt = start

        state = GameEngine.advance(state, to: .now)
        #expect(state.age >= 3)
    }

    @Test
    func `dead pet is not advanced`() {
        var state = makeTestState(hunger: 4)
        state.isDead = true
        let original = state
        state = GameEngine.advance(state, to: .now)
        #expect(
            state.hungerHearts.value
                == original.hungerHearts.value
        )
    }

    @Test
    func `egg is not advanced`() {
        var state = PetState.newEgg()
        let original = state
        state = GameEngine.advance(state, to: .now)
        #expect(state.isEgg == original.isEgg)
    }
}
