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
        #expect(
            SleepSchedule.isNight(weatherNight: true, at: date(hour: 15), for: .emberkin)
        )
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

    // MARK: - Day

    @Test
    func `daytime forces the light on and keeps the pet awake`() {
        var state = makeTestState(at: .now)
        state.lightsOn = false
        state.isSleeping = true

        state = SleepSchedule.apply(to: state, at: .now, night: false)

        #expect(state.lightsOn == true)
        #expect(state.isSleeping == false)
    }

    // MARK: - Dusk / Dawn

    @Test
    func `dusk turns the light off and starts the settle countdown`() {
        let now = Date()
        var state = makeTestState(at: now)
        state.lightsOn = true
        state.isSleeping = false
        state.wasNight = false

        state = SleepSchedule.apply(to: state, at: now, night: true)

        #expect(state.lightsOn == false)
        #expect(state.wasNight == true)
        #expect(state.isSleeping == false)              // not yet — settling
        #expect(state.timestamps.lightsOffAt == now)
    }

    @Test
    func `dawn turns the light on and wakes the pet`() {
        let now = Date()
        var state = makeTestState(at: now)
        state.lightsOn = false
        state.isSleeping = true
        state.wasNight = true

        state = SleepSchedule.apply(to: state, at: now, night: false)

        #expect(state.lightsOn == true)
        #expect(state.isSleeping == false)
        #expect(state.wasNight == false)
    }

    // MARK: - Settle Delay

    @Test
    func `pet sleeps once the settle delay has passed`() {
        let now = Date()
        var state = makeTestState(at: now)
        state.wasNight = true
        state.lightsOn = false
        state.isSleeping = false
        state.timestamps.lightsOffAt = now.addingTimeInterval(
            -(TimeConstants.sleepDelay + 1)
        )

        state = SleepSchedule.apply(to: state, at: now, night: true)

        #expect(state.isSleeping == true)
        #expect(state.timestamps.lightsOffAt == nil)
    }

    @Test
    func `pet stays awake before the settle delay`() {
        let now = Date()
        var state = makeTestState(at: now)
        state.wasNight = true
        state.lightsOn = false
        state.isSleeping = false
        state.timestamps.lightsOffAt = now.addingTimeInterval(-1)

        state = SleepSchedule.apply(to: state, at: now, night: true)

        #expect(state.isSleeping == false)
    }

    @Test
    func `light on at night keeps the pet awake`() {
        let now = Date()
        var state = makeTestState(at: now)
        state.wasNight = true
        state.lightsOn = true

        state = SleepSchedule.apply(to: state, at: now, night: true)

        #expect(state.lightsOn == true)
        #expect(state.isSleeping == false)
    }

    @Test
    func `sleeping pet stays asleep with the light off`() {
        let now = Date()
        var state = makeTestState(at: now)
        state.wasNight = true
        state.lightsOn = false
        state.isSleeping = true

        state = SleepSchedule.apply(to: state, at: now, night: true)

        #expect(state.isSleeping == true)
    }

    // MARK: - Guards

    @Test
    func `dead pet is not affected`() {
        var state = makeTestState(at: .now)
        state.isDead = true
        state.isSleeping = false

        state = SleepSchedule.apply(to: state, at: .now, night: true)

        #expect(state.isSleeping == false)
    }

    @Test
    func `egg is not affected`() {
        var state = PetState.newEgg(at: .now)
        state.isSleeping = false

        state = SleepSchedule.apply(to: state, at: .now, night: true)

        #expect(state.isSleeping == false)
    }
}
