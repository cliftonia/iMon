import Testing
import Foundation
@testable import imon_Watch_App

@Suite("SleepSchedule")
struct SleepScheduleTests {

    // MARK: - Helpers

    private func date(hour: Int) -> Date {
        var components = Calendar.current.dateComponents(
            [.year, .month, .day], from: .now
        )
        components.hour = hour
        components.minute = 0
        components.second = 0
        return Calendar.current.date(from: components) ?? .now
    }

    // MARK: - Night Resolution

    @Test
    func `weather daylight overrides the clock`() {
        // 3pm by the clock, but the weather reports night.
        #expect(
            SleepSchedule.isNight(weatherNight: true, at: date(hour: 15), for: .emberkin)
        )
        // 11pm by the clock, but the weather reports day.
        #expect(
            !SleepSchedule.isNight(weatherNight: false, at: date(hour: 23), for: .emberkin)
        )
    }

    @Test
    func `falls back to fixed hours without weather`() {
        // Emberkin sleeps 21:00–07:00.
        #expect(
            SleepSchedule.isNight(weatherNight: nil, at: date(hour: 22), for: .emberkin)
        )
        #expect(
            !SleepSchedule.isNight(weatherNight: nil, at: date(hour: 14), for: .emberkin)
        )
    }

    // MARK: - Apply

    @Test
    func `daytime forces the light on and keeps the pet awake`() {
        var state = makeTestState(at: .now)
        state.lightsOn = false
        state.isSleeping = true

        state = SleepSchedule.apply(to: state, night: false)

        #expect(state.lightsOn == true)
        #expect(state.isSleeping == false)
    }

    @Test
    func `dusk turns the light off and sends the pet to sleep`() {
        var state = makeTestState(at: .now)
        state.lightsOn = true
        state.isSleeping = false
        state.wasNight = false

        state = SleepSchedule.apply(to: state, night: true)

        #expect(state.lightsOn == false)
        #expect(state.isSleeping == true)
        #expect(state.wasNight == true)
    }

    @Test
    func `dawn turns the light on and wakes the pet`() {
        var state = makeTestState(at: .now)
        state.lightsOn = false
        state.isSleeping = true
        state.wasNight = true

        state = SleepSchedule.apply(to: state, night: false)

        #expect(state.lightsOn == true)
        #expect(state.isSleeping == false)
        #expect(state.wasNight == false)
    }

    @Test
    func `light left on at night keeps the pet awake`() {
        var state = makeTestState(at: .now)
        state.wasNight = true   // already night, no transition
        state.lightsOn = true   // player turned it on

        state = SleepSchedule.apply(to: state, night: true)

        #expect(state.lightsOn == true)
        #expect(state.isSleeping == false)
    }

    @Test
    func `light off at night lets the pet sleep`() {
        var state = makeTestState(at: .now)
        state.wasNight = true
        state.lightsOn = false

        state = SleepSchedule.apply(to: state, night: true)

        #expect(state.isSleeping == true)
    }

    // MARK: - Guards

    @Test
    func `dead pet is not affected`() {
        var state = makeTestState(at: .now)
        state.isDead = true
        state.isSleeping = false

        state = SleepSchedule.apply(to: state, night: true)

        #expect(state.isSleeping == false)
    }

    @Test
    func `egg is not affected`() {
        var state = PetState.newEgg(at: .now)
        state.isSleeping = false

        state = SleepSchedule.apply(to: state, night: true)

        #expect(state.isSleeping == false)
    }
}
