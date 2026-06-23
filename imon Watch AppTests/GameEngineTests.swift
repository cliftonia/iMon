import Testing
import Foundation
@testable import imon_Watch_App

@Suite("GameEngine")
struct GameEngineTests {

    @Test
    func `advance updates age in days`() {
        let start = Date.now.addingTimeInterval(-86400 * 3)
        var state = makeTestState(at: start)
        state.timestamps.bornAt = start

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
    func `an egg stays frozen across days until it hatches`() {
        let born = Date.now.addingTimeInterval(-86400 * 5)
        var state = PetState.newEgg()
        state.timestamps.bornAt = born
        let original = state

        // Five days on, the engine must still short-circuit the egg: it neither
        // hatches itself nor drains the stats the simulators would touch.
        state = GameEngine.advance(state, to: .now)
        #expect(state.isEgg)
        #expect(state.hungerHearts.value == original.hungerHearts.value)
        #expect(state.poopCount == original.poopCount)
    }
}
