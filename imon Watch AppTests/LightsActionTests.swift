import Testing
import Foundation
@testable import imon_Watch_App

@Suite("LightsAction")
struct LightsActionTests {

    // MARK: - Helpers

    private func date(hour: Int) -> Date {
        var components = Calendar.current.dateComponents(
            [.year, .month, .day], from: .now
        )
        components.hour = hour
        components.minute = 0
        components.second = 0
        return Calendar.current.date(from: components)!
    }

    // MARK: - Outside Sleep Hours

    @Test
    func `toggle outside sleep hours returns toggled`() {
        let afternoon = date(hour: 14)
        var state = makeTestState(at: afternoon)
        state.lightsOn = true

        let (newState, result) = LightsAction.apply(
            to: state, at: afternoon
        )

        #expect(result == .toggled)
        #expect(newState.lightsOn == false)
        #expect(newState.lightsToggledDuringSleepAt == nil)
    }

    // MARK: - During Sleep Hours

    @Test
    func `toggle during sleep hours returns toggledDuringSleep`() {
        let nightTime = date(hour: 22)
        var state = makeTestState(at: nightTime)
        state.lightsOn = false

        let (newState, result) = LightsAction.apply(
            to: state, at: nightTime
        )

        #expect(result == .toggledDuringSleep)
        #expect(newState.lightsOn == true)
        #expect(newState.lightsToggledDuringSleepAt == nightTime)
    }

    // MARK: - Blocked

    @Test
    func `cannot toggle dead pet`() {
        let now = date(hour: 14)
        var state = makeTestState(at: now)
        state.isDead = true

        let (_, result) = LightsAction.apply(to: state, at: now)

        #expect(result == .blocked)
    }

    @Test
    func `cannot toggle egg`() {
        let now = date(hour: 14)
        let state = PetState.newEgg(at: now)

        let (_, result) = LightsAction.apply(to: state, at: now)

        #expect(result == .blocked)
    }
}
