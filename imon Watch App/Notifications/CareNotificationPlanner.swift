import Foundation

/// Computes the care reminders to schedule for a backgrounded pet. Pure and
/// deterministic: each event's fire time comes from its anchor timestamp plus a
/// base interval (future activity is unknown, so the estimate is approximate).
/// Past events and any that would land while the pet sleeps (the night window)
/// are dropped, so the owner is never buzzed at 2am.
nonisolated enum CareNotificationPlanner {

    /// `steps` is today's running step count and scales the hunger/strength
    /// estimates exactly as the simulators do; `nil` (steps disabled or
    /// unavailable) estimates at the base rates and skips the exercise nudge.
    static func plan(
        for state: PetState,
        now: Date,
        steps: Int?
    ) -> [CareNotification] {
        guard !state.isDead, !state.isEgg else { return [] }

        var candidates: [CareNotification] = []
        let times = state.timestamps
        let calendar = Calendar.current

        // Scale by activity as the simulators do — a fast-draining pet is flagged late otherwise.
        let hungerInterval = TimeConstants.hungerDepletionInterval
            / (steps.map { ActivityModel.hungerRateMultiplier(steps: $0) } ?? 1.0)
        let strengthInterval = TimeConstants.strengthDepletionInterval
            / (steps.map { ActivityModel.strengthRateMultiplier(steps: $0) } ?? 1.0)

        if state.hungerHearts.value > 0 {
            let fire = times.lastHungerDecayAt.addingTimeInterval(
                Double(state.hungerHearts.value) * hungerInterval
            )
            candidates.append(CareNotification(kind: .hunger, fireDate: fire, species: state.species))
        }
        if state.strengthHearts.value > 0 {
            let fire = times.lastStrengthDecayAt.addingTimeInterval(
                Double(state.strengthHearts.value) * strengthInterval
            )
            candidates.append(CareNotification(kind: .strength, fireDate: fire, species: state.species))
        }

        if state.poopCount < TimeConstants.maxPoopPiles {
            let fire = times.lastPoopAt.addingTimeInterval(TimeConstants.poopInterval)
            candidates.append(CareNotification(kind: .mess, fireDate: fire, species: state.species))
        }

        // Injury — remind partway to the untreated-injury death window.
        if state.isInjured, let injuredAt = times.injuredAt {
            let fire = injuredAt.addingTimeInterval(TimeConstants.untreatedInjuryDeathTime / 2)
            candidates.append(CareNotification(kind: .injury, fireDate: fire, species: state.species))
        }

        // Fading — warn before a languishing pet finally collapses to death.
        if let collapsingAt = times.collapsingAt {
            let fire = collapsingAt.addingTimeInterval(
                TimeConstants.collapseDeathTime - TimeConstants.nearingDeathLead
            )
            candidates.append(CareNotification(kind: .fading, fireDate: fire, species: state.species))
        }

        // Exercise — nudge a lazy wearer to get moving once the afternoon is gone.
        let hour = calendar.component(.hour, from: now)
        if let steps, hour >= TimeConstants.exerciseHour, steps < TimeConstants.exerciseStepTarget {
            let fire = now.addingTimeInterval(TimeConstants.exerciseNudgeLead)
            candidates.append(CareNotification(kind: .exercise, fireDate: fire, species: state.species))
        }

        return candidates
            .filter { $0.fireDate > now }
            .map { deferredPastNight($0, calendar: calendar) }
            .sorted { $0.fireDate < $1.fireDate }
    }

    /// Moves a reminder that would land in the night window to the following
    /// morning rather than dropping it — the pet still needs care, and a buzz
    /// at 2am serves nobody. A death warning is exempt: it must fire when the
    /// pet is actually dying.
    private static func deferredPastNight(
        _ notification: CareNotification,
        calendar: Calendar
    ) -> CareNotification {
        guard notification.kind != .fading,
              SleepSchedule.isNight(weatherNight: nil, at: notification.fireDate)
        else { return notification }

        return CareNotification(
            kind: notification.kind,
            fireDate: nextMorning(after: notification.fireDate, calendar: calendar),
            species: notification.species
        )
    }

    /// The next `nightEndHour` strictly after `date`.
    private static func nextMorning(after date: Date, calendar: Calendar) -> Date {
        let isBeforeDawn = calendar.component(.hour, from: date) < TimeConstants.nightEndHour
        let day = isBeforeDawn
            ? date
            : calendar.date(byAdding: .day, value: 1, to: date) ?? date
        return calendar.date(
            bySettingHour: TimeConstants.nightEndHour, minute: 0, second: 0, of: day
        ) ?? date
    }
}
