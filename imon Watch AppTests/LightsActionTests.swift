import Testing
import Foundation
@testable import imon_Watch_App

@Suite("LightsAction")
struct LightsActionTests {

    @Test
    func `cannot toggle during the day`() {
        var state = makeTestState(at: .now)
        state.lightsOn = true

        let (newState, result) = LightsAction.apply(to: state, night: false)

        #expect(result == .blocked)
        #expect(newState.lightsOn == true)
    }

    @Test
    func `turning the light off at night sleeps the pet`() {
        var state = makeTestState(at: .now)
        state.lightsOn = true
        state.isSleeping = false

        let (newState, result) = LightsAction.apply(to: state, night: true)

        #expect(result == .toggled)
        #expect(newState.lightsOn == false)
        #expect(newState.isSleeping == true)
    }

    @Test
    func `turning the light on at night wakes the pet`() {
        var state = makeTestState(at: .now)
        state.lightsOn = false
        state.isSleeping = true

        let (newState, result) = LightsAction.apply(to: state, night: true)

        #expect(result == .toggled)
        #expect(newState.lightsOn == true)
        #expect(newState.isSleeping == false)
    }

    @Test
    func `cannot toggle dead pet`() {
        var state = makeTestState(at: .now)
        state.isDead = true

        let (_, result) = LightsAction.apply(to: state, night: true)

        #expect(result == .blocked)
    }

    @Test
    func `cannot toggle egg`() {
        let state = PetState.newEgg(at: .now)

        let (_, result) = LightsAction.apply(to: state, night: true)

        #expect(result == .blocked)
    }
}
