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
        let name = state.species.displayName

        // Hunger / strength reach empty. Scale by activity exactly as the
        // simulators do, or an active wearer's faster-draining pet would be
        // flagged late (it's already starving by the time the alert fires).
        let hungerInterval = TimeConstants.hungerDepletionInterval
            / (steps.map { ActivityModel.hungerRateMultiplier(steps: $0) } ?? 1.0)
        let strengthInterval = TimeConstants.strengthDepletionInterval
            / (steps.map { ActivityModel.strengthRateMultiplier(steps: $0) } ?? 1.0)

        if state.hungerHearts.value > 0 {
            let fire = times.lastHungerDecayAt.addingTimeInterval(
                Double(state.hungerHearts.value) * hungerInterval
            )
            candidates.append(CareNotification(kind: .hunger, fireDate: fire, petName: name))
        }
        if state.strengthHearts.value > 0 {
            let fire = times.lastStrengthDecayAt.addingTimeInterval(
                Double(state.strengthHearts.value) * strengthInterval
            )
            candidates.append(CareNotification(kind: .strength, fireDate: fire, petName: name))
        }

        // Next mess, until the pile cap is reached.
        if state.poopCount < TimeConstants.maxPoopPiles {
            let fire = times.lastPoopAt.addingTimeInterval(TimeConstants.poopInterval)
            candidates.append(CareNotification(kind: .mess, fireDate: fire, petName: name))
        }

        // Injury — remind partway to the untreated-injury death window.
        if state.isInjured, let injuredAt = times.injuredAt {
            let fire = injuredAt.addingTimeInterval(TimeConstants.untreatedInjuryDeathTime / 2)
            candidates.append(CareNotification(kind: .injury, fireDate: fire, petName: name))
        }

        // Fading — warn before a languishing pet finally collapses to death.
        if let collapsingAt = times.collapsingAt {
            let fire = collapsingAt.addingTimeInterval(
                TimeConstants.collapseDeathTime - TimeConstants.nearingDeathLead
            )
            candidates.append(CareNotification(kind: .fading, fireDate: fire, petName: name))
        }

        // Exercise — nudge a lazy wearer to get moving once the afternoon is gone.
        let hour = Calendar.current.component(.hour, from: now)
        if let steps, hour >= TimeConstants.exerciseHour, steps < TimeConstants.exerciseStepTarget {
            let fire = now.addingTimeInterval(TimeConstants.exerciseNudgeLead)
            candidates.append(CareNotification(kind: .exercise, fireDate: fire, petName: name))
        }

        return candidates
            .filter { $0.fireDate > now }
            // Night-time events are dropped so the owner isn't buzzed at 2am — but
            // a death warning is important enough to fire whenever it's due.
            .filter {
                $0.kind == .fading
                    || !SleepSchedule.isNight(weatherNight: nil, at: $0.fireDate)
            }
            .sorted { $0.fireDate < $1.fireDate }
    }
}
