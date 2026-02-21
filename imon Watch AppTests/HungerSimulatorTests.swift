import Testing
import Foundation
@testable import imon_Watch_App

@Suite("HungerSimulator")
struct HungerSimulatorTests {

    @Test
    func `depletes one heart per interval`() {
        let start = Date.now
        var state = makeTestState(hunger: 4, at: start)
        state.lastHungerDecayAt = start

        let later = start.addingTimeInterval(
            TimeConstants.hungerDepletionInterval
        )
        state = HungerSimulator.apply(to: state, at: later)
        #expect(state.hungerHearts.value == 3)
    }

    @Test
    func `multiple intervals deplete multiple hearts`() {
        let start = Date.now
        var state = makeTestState(hunger: 4, at: start)
        state.lastHungerDecayAt = start

        let later = start.addingTimeInterval(
            TimeConstants.hungerDepletionInterval * 3
        )
        state = HungerSimulator.apply(to: state, at: later)
        #expect(state.hungerHearts.value == 1)
    }

    @Test
    func `does not deplete while sleeping`() {
        let start = Date.now
        var state = makeTestState(hunger: 4, at: start)
        state.isSleeping = true
        state.lastHungerDecayAt = start

        let later = start.addingTimeInterval(
            TimeConstants.hungerDepletionInterval * 5
        )
        state = HungerSimulator.apply(to: state, at: later)
        #expect(state.hungerHearts.value == 4)
    }
}
