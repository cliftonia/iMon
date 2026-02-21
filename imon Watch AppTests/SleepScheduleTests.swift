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
        return Calendar.current.date(from: components)!
    }

    // MARK: - Bedtime / Wake Transitions

    @Test
    func `pet falls asleep at bedtime`() {
        let bedtime = date(hour: 21) // agumon bedtime
        var state = makeTestState(at: bedtime)
        state.isSleeping = false
        state.lightsOn = true

        state = SleepSchedule.apply(to: state, at: bedtime)

        #expect(state.isSleeping == true)
        #expect(state.lightsOn == false)
    }

    @Test
    func `pet wakes at wake hour`() {
        let morning = date(hour: 7)
        var state = makeTestState(at: morning)
        state.isSleeping = true
        state.lightsOn = false

        state = SleepSchedule.apply(to: state, at: morning)

        #expect(state.isSleeping == false)
        #expect(state.lightsOn == true)
    }

    // MARK: - Pending Toggle Guard

    @Test
    func `does not re-sleep if user has pending toggle`() {
        let bedtime = date(hour: 22)
        var state = makeTestState(at: bedtime)
        state.isSleeping = false
        state.lightsOn = true
        state.lightsToggledDuringSleepAt = bedtime

        state = SleepSchedule.apply(to: state, at: bedtime)

        #expect(state.isSleeping == false)
    }

    // MARK: - Pending Toggle Resolution

    @Test
    func `resolves pending toggle after 5s — lights on wakes pet`() {
        let toggleTime = date(hour: 22)
        let resolveTime = toggleTime.addingTimeInterval(5)
        var state = makeTestState(at: toggleTime)
        state.isSleeping = true
        state.lightsOn = true
        state.lightsToggledDuringSleepAt = toggleTime

        state = SleepSchedule.apply(to: state, at: resolveTime)

        #expect(state.isSleeping == false)
        #expect(state.lightsToggledDuringSleepAt != nil)
    }

    @Test
    func `wake resolve guards against bedtime re-sleep on next tick`() {
        let toggleTime = date(hour: 22)
        let afterResolve = toggleTime.addingTimeInterval(35)
        var state = makeTestState(at: toggleTime)
        state.isSleeping = false
        state.lightsOn = true
        state.lightsToggledDuringSleepAt = toggleTime

        state = SleepSchedule.apply(to: state, at: afterResolve)

        #expect(state.isSleeping == false)
    }

    @Test
    func `resolves pending toggle after 5s — lights off sleeps pet`() {
        let toggleTime = date(hour: 22)
        let resolveTime = toggleTime.addingTimeInterval(5)
        var state = makeTestState(at: toggleTime)
        state.isSleeping = false
        state.lightsOn = false
        state.lightsToggledDuringSleepAt = toggleTime

        state = SleepSchedule.apply(to: state, at: resolveTime)

        #expect(state.isSleeping == true)
        #expect(state.lightsToggledDuringSleepAt == nil)
    }

    @Test
    func `does not resolve before 5s`() {
        let toggleTime = date(hour: 22)
        let tooEarly = toggleTime.addingTimeInterval(4)
        var state = makeTestState(at: toggleTime)
        state.isSleeping = true
        state.lightsOn = true
        state.lightsToggledDuringSleepAt = toggleTime

        state = SleepSchedule.apply(to: state, at: tooEarly)

        #expect(state.lightsToggledDuringSleepAt != nil)
        #expect(state.isSleeping == true)
    }

    // MARK: - Guards

    @Test
    func `dead pet is not affected`() {
        let bedtime = date(hour: 21)
        var state = makeTestState(at: bedtime)
        state.isDead = true
        state.isSleeping = false

        state = SleepSchedule.apply(to: state, at: bedtime)

        #expect(state.isSleeping == false)
    }

    @Test
    func `egg is not affected`() {
        let bedtime = date(hour: 21)
        var state = PetState.newEgg(at: bedtime)
        state.isSleeping = false

        state = SleepSchedule.apply(to: state, at: bedtime)

        #expect(state.isSleeping == false)
    }

    // MARK: - Leaving Sleep Hours

    @Test
    func `wake transition clears pending toggle timestamp`() {
        let morning = date(hour: 7)
        var state = makeTestState(at: morning)
        state.isSleeping = true
        state.lightsOn = false
        state.lightsToggledDuringSleepAt = morning

        state = SleepSchedule.apply(to: state, at: morning)

        #expect(state.lightsToggledDuringSleepAt == nil)
    }

    @Test
    func `leaving sleep hours clears wake override`() {
        let morning = date(hour: 7)
        var state = makeTestState(at: morning)
        state.isSleeping = false
        state.lightsOn = true
        state.lightsToggledDuringSleepAt = morning

        state = SleepSchedule.apply(to: state, at: morning)

        #expect(state.lightsToggledDuringSleepAt == nil)
        #expect(state.isSleeping == false)
    }
}
