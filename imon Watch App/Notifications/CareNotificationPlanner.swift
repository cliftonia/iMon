import Foundation

/// Computes the care reminders to schedule for a backgrounded pet. Pure and
/// deterministic: each event's fire time comes from its anchor timestamp plus a
/// base interval of *waking* time (future activity is unknown, so the estimate
/// is approximate). Hunger, strength and mess pause overnight exactly as the
/// engine pauses them, so a projection that crosses bedtime resumes at dawn.
/// Past events and any that would land while the pet sleeps (the night window)
/// are held to morning or dropped, so the owner is never buzzed at 2am.
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

        if state.hungerHearts.value > 0, let fire = wakingProjection(
            from: times.lastHungerDecayAt, ticks: state.hungerHearts.value,
            interval: hungerInterval, calendar: calendar
        ) {
            candidates.append(CareNotification(kind: .hunger, fireDate: fire, species: state.species))
        }
        if state.strengthHearts.value > 0, let fire = wakingProjection(
            from: times.lastStrengthDecayAt, ticks: state.strengthHearts.value,
            interval: strengthInterval, calendar: calendar
        ) {
            candidates.append(CareNotification(kind: .strength, fireDate: fire, species: state.species))
        }

        if state.poopCount < TimeConstants.maxPoopPiles, let fire = wakingProjection(
            from: times.lastPoopAt, ticks: 1, interval: TimeConstants.poopInterval, calendar: calendar
        ) {
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
            .compactMap { nightAdjusted($0, times: times, calendar: calendar) }
            .sorted { $0.fireDate < $1.fireDate }
    }

    /// The night policy. A death warning fires whenever it is due. A reminder
    /// whose need survives the night is held to the wake hour rather than
    /// dropped. Everything else is dropped, because a reminder that has
    /// outlived its meaning is worse than silence.
    private static func nightAdjusted(
        _ notification: CareNotification,
        times: PetState.Timestamps,
        calendar: Calendar
    ) -> CareNotification? {
        guard notification.kind != .fading,
              SleepSchedule.isNight(weatherNight: nil, at: notification.fireDate)
        else { return notification }

        guard let morning = nextMorning(after: notification.fireDate, calendar: calendar),
              stillMeaningful(notification.kind, at: morning, times: times)
        else { return nil }

        return CareNotification(
            kind: notification.kind,
            // Stagger by kind so several held reminders do not all buzz at once.
            fireDate: morning.addingTimeInterval(morningOffset(for: notification.kind)),
            species: notification.species
        )
    }

    /// Whether a reminder held until `morning` still says something true.
    private static func stillMeaningful(
        _ kind: CareNotification.Kind,
        at morning: Date,
        times: PetState.Timestamps
    ) -> Bool {
        switch kind {
        case .hunger, .strength, .mess:
            // The pet is just as hungry, weak or filthy when the owner wakes.
            true
        case .injury:
            // Pointless past the untreated-injury death window — by then the
            // pet is already in its grave.
            times.injuredAt.map {
                morning < $0.addingTimeInterval(TimeConstants.untreatedInjuryDeathTime)
            } ?? false
        case .exercise:
            // A nudge about a step total the owner can no longer influence.
            false
        case .fading:
            true
        }
    }

    private static func morningOffset(for kind: CareNotification.Kind) -> TimeInterval {
        switch kind {
        case .hunger: 0
        case .strength: 120
        case .mess: 240
        case .injury: 360
        case .exercise, .fading: 0
        }
    }

    /// When `ticks` intervals of waking time complete, counting from `anchor`.
    /// The bedtime window (`SleepSchedule.isBedtime`) is skipped, mirroring the
    /// engine: a sleeping pet's clocks freeze and restart at dawn. An anchor
    /// already inside the window jumps to the morning first, since waking
    /// re-anchors there. Nil when the calendar cannot name a morning.
    private static func wakingProjection(
        from anchor: Date,
        ticks: Int,
        interval: TimeInterval,
        calendar: Calendar
    ) -> Date? {
        var moment = anchor
        var remaining = Double(ticks) * interval
        for _ in 0..<SleepSchedule.maxReplayDays {
            if SleepSchedule.isBedtime(at: moment, calendar: calendar) {
                guard let morning = nextMorning(after: moment, calendar: calendar) else { return nil }
                moment = morning
            }
            guard let settle = nextSettle(after: moment, calendar: calendar) else { return nil }
            let awake = settle.timeIntervalSince(moment)
            if remaining <= awake { return moment.addingTimeInterval(remaining) }
            remaining -= awake
            moment = settle
        }
        return nil
    }

    /// The next moment the pet settles to sleep (bedtime plus the settle delay)
    /// strictly after `date`.
    private static func nextSettle(after date: Date, calendar: Calendar) -> Date? {
        guard let bedtime = calendar.date(
            bySettingHour: TimeConstants.sleepHour, minute: 0, second: 0, of: date
        ) else { return nil }
        let settle = bedtime.addingTimeInterval(TimeConstants.sleepDelay)
        if settle > date { return settle }
        return calendar.date(byAdding: .day, value: 1, to: settle)
    }

    /// The next `nightEndHour` strictly after `date`, or nil if the calendar
    /// cannot name that instant — dropping beats buzzing at 2am.
    private static func nextMorning(after date: Date, calendar: Calendar) -> Date? {
        let isBeforeDawn = calendar.component(.hour, from: date) < TimeConstants.nightEndHour
        guard let day = isBeforeDawn
            ? date
            : calendar.date(byAdding: .day, value: 1, to: date)
        else { return nil }
        return calendar.date(
            bySettingHour: TimeConstants.nightEndHour, minute: 0, second: 0, of: day
        )
    }
}
