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
    func `a starved and weak pet collapses to death over time`() {
        let start = Date.now
        var state = makeTestState(hunger: 0, strength: 0, at: start)
        state.timestamps.lastHungerDecayAt = start
        state.timestamps.lastStrengthDecayAt = start

        // First advance arms the collapse countdown but doesn't kill yet.
        state = GameEngine.advance(state, to: start.addingTimeInterval(60))
        #expect(state.isDead == false)
        #expect(state.timestamps.collapsingAt != nil)

        // Left languishing past the window, it perishes.
        state = GameEngine.advance(
            state, to: start.addingTimeInterval(TimeConstants.collapseDeathTime + 120)
        )
        #expect(state.isDead)
    }

    @Test
    func `an egg stays frozen across days until it hatches`() {
        let born = Date.now.addingTimeInterval(-86400 * 5)
        var state = PetState.hatched(at: .now)
        state.isEgg = true
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
