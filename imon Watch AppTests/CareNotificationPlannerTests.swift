import Testing
import Foundation
@testable import imon_Watch_App

@Suite("CareNotificationPlanner")
struct CareNotificationPlannerTests {

    /// A fixed calendar day at the given local hour, so day/night filtering is
    /// deterministic in any timezone (planner and test share `Calendar.current`).
    private func today(at hour: Int) -> Date {
        let calendar = Calendar.current
        let anchor = Date(timeIntervalSince1970: 1_700_000_000)
        let midnight = calendar.startOfDay(for: anchor)
        return calendar.date(byAdding: .hour, value: hour, to: midnight) ?? midnight
    }

    private func notification(
        _ plan: [CareNotification], _ kind: CareNotification.Kind
    ) -> CareNotification? {
        plan.first { $0.kind == kind }
    }

    @Test
    func `hunger fires when the remaining hearts empty`() {
        let now = today(at: 8)
        let state = makeTestState(species: .emberkin, hunger: 2, at: now)
        let plan = CareNotificationPlanner.plan(for: state, now: now, steps: nil)

        let hunger = notification(plan, .hunger)
        let expected = now.addingTimeInterval(2 * TimeConstants.hungerDepletionInterval)
        #expect(hunger?.fireDate == expected)
    }

    @Test
    func `strength fires when the remaining hearts empty`() {
        let now = today(at: 8)
        let state = makeTestState(species: .emberkin, strength: 3, at: now)
        let plan = CareNotificationPlanner.plan(for: state, now: now, steps: nil)

        let strength = notification(plan, .strength)
        let expected = now.addingTimeInterval(3 * TimeConstants.strengthDepletionInterval)
        #expect(strength?.fireDate == expected)
    }

    @Test
    func `mess is scheduled below the pile cap and not at it`() {
        let now = today(at: 8)
        var below = makeTestState(at: now)
        below.poopCount = TimeConstants.maxPoopPiles - 1
        #expect(notification(
            CareNotificationPlanner.plan(for: below, now: now, steps: nil), .mess
        ) != nil)

        var full = makeTestState(at: now)
        full.poopCount = TimeConstants.maxPoopPiles
        #expect(notification(
            CareNotificationPlanner.plan(for: full, now: now, steps: nil), .mess
        ) == nil)
    }

    @Test
    func `injury reminds at half the death window`() {
        let now = today(at: 8)
        var state = makeTestState(at: now)
        state.isInjured = true
        state.timestamps.injuredAt = now
        let plan = CareNotificationPlanner.plan(for: state, now: now, steps: nil)

        let injury = notification(plan, .injury)
        let expected = now.addingTimeInterval(TimeConstants.untreatedInjuryDeathTime / 2)
        #expect(injury?.fireDate == expected)
    }

    @Test
    func `a sedentary wearer gets a walk nudge, an active one does not`() {
        let now = today(at: 8)
        let state = makeTestState(at: now)
        #expect(notification(
            CareNotificationPlanner.plan(for: state, now: now, steps: 0), .walk
        ) != nil)
        #expect(notification(
            CareNotificationPlanner.plan(for: state, now: now, steps: 8_000), .walk
        ) == nil)
        #expect(notification(
            CareNotificationPlanner.plan(for: state, now: now, steps: nil), .walk
        ) == nil)
    }

    @Test
    func `night-time events are dropped`() {
        // Only a walk candidate (hunger/strength empty, piles maxed, not injured).
        var state = makeTestState(species: .emberkin, hunger: 0, strength: 0)
        state.poopCount = TimeConstants.maxPoopPiles

        // 16:00 + 3h walk lead = 19:00 → night → dropped.
        let night = today(at: 16)
        #expect(CareNotificationPlanner.plan(for: state, now: night, steps: 0).isEmpty)

        // 09:00 + 3h = 12:00 → daytime → kept.
        let day = today(at: 9)
        #expect(notification(
            CareNotificationPlanner.plan(for: state, now: day, steps: 0), .walk
        ) != nil)
    }

    @Test
    func `past events are dropped`() {
        let base = today(at: 8)
        let state = makeTestState(at: base)
        let later = base.addingTimeInterval(100_000)  // long after every anchor
        #expect(CareNotificationPlanner.plan(for: state, now: later, steps: nil).isEmpty)
    }

    @Test
    func `dead or egg pets get no notifications`() {
        let now = today(at: 8)
        var dead = makeTestState(at: now)
        dead.isDead = true
        #expect(CareNotificationPlanner.plan(for: dead, now: now, steps: 0).isEmpty)

        var egg = makeTestState(at: now)
        egg.isEgg = true
        #expect(CareNotificationPlanner.plan(for: egg, now: now, steps: 0).isEmpty)
    }

    @Test
    func `each notification carries a stable per-kind id`() {
        // Stable ids are the dedup contract — a re-plan must replace the pending
        // reminder of the same kind, not stack a second one.
        let now = today(at: 8)
        let plan = CareNotificationPlanner.plan(for: makeTestState(at: now), now: now, steps: nil)
        for note in plan {
            #expect(note.id == note.kind.rawValue)
        }
    }
}
