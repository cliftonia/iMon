import Foundation

/// Computes the care reminders to schedule for a backgrounded pet. Pure and
/// deterministic: each event's fire time comes from its anchor timestamp plus a
/// base interval (future activity is unknown, so the estimate is approximate).
/// Past events and any that would land while the pet sleeps (the night window)
/// are dropped, so the owner is never buzzed at 2am.
nonisolated enum CareNotificationPlanner {

    static func plan(
        for state: PetState,
        now: Date,
        steps: Int?
    ) -> [CareNotification] {
        guard !state.isDead, !state.isEgg else { return [] }

        var candidates: [CareNotification] = []
        let times = state.timestamps

        // Hunger / strength reach empty.
        if state.hungerHearts.value > 0 {
            let fire = times.lastHungerDecayAt.addingTimeInterval(
                Double(state.hungerHearts.value) * TimeConstants.hungerDepletionInterval
            )
            candidates.append(CareNotification(kind: .hunger, fireDate: fire))
        }
        if state.strengthHearts.value > 0 {
            let fire = times.lastStrengthDecayAt.addingTimeInterval(
                Double(state.strengthHearts.value) * TimeConstants.strengthDepletionInterval
            )
            candidates.append(CareNotification(kind: .strength, fireDate: fire))
        }

        // Next mess, until the pile cap is reached.
        if state.poopCount < TimeConstants.maxPoopPiles {
            let fire = times.lastPoopAt.addingTimeInterval(TimeConstants.poopInterval)
            candidates.append(CareNotification(kind: .mess, fireDate: fire))
        }

        // Injury — remind partway to the untreated-injury death window.
        if state.isInjured, let injuredAt = times.injuredAt {
            let fire = injuredAt.addingTimeInterval(TimeConstants.untreatedInjuryDeathTime / 2)
            candidates.append(CareNotification(kind: .injury, fireDate: fire))
        }

        // Walk — nudge a sedentary wearer to get moving, like a restless dog.
        if let steps, ActivityModel.isSedentary(steps: steps) {
            let fire = now.addingTimeInterval(TimeConstants.walkNudgeLead)
            candidates.append(CareNotification(kind: .walk, fireDate: fire))
        }

        return candidates
            .filter { $0.fireDate > now }
            .filter { !SleepSchedule.isNight(weatherNight: nil, at: $0.fireDate) }
            .sorted { $0.fireDate < $1.fireDate }
    }
}
