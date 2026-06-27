import Foundation

/// The work performed on a background wake: advance the saved pet to `now`,
/// persist it, re-arm the next wake, and re-evaluate the care reminders against
/// the fresh state. Self-contained — it reads and writes the store directly, so
/// it runs on a bare background launch with no SwiftUI scene. Reuses the existing
/// engine and the care-notification planner; it introduces no new game logic.
nonisolated enum BackgroundTick {

    static func perform(
        store: PetStateStore,
        notifications: NotificationScheduler,
        refresh: BackgroundRefreshScheduler,
        steps: Int?,
        now: Date
    ) {
        // A transient decode failure must not break the wake chain — re-arm and
        // bail. A genuine absence of a saved pet (hatching) is a true no-op.
        let loaded: PetState?
        do {
            loaded = try store.load()
        } catch {
            refresh.schedule(now.addingTimeInterval(TimeConstants.backgroundRefreshInterval))
            return
        }
        guard let state = loaded else { return }

        let advanced = GameEngine.advance(state, to: now, isNight: nil, steps: steps)
        try? store.save(advanced)

        // Re-arm the next wake before the caller completes the task, so the loop
        // keeps going even if the work below is later cut short.
        refresh.schedule(
            now.addingTimeInterval(TimeConstants.backgroundRefreshInterval)
        )

        let plan = CareNotificationPlanner.plan(for: advanced, now: now, steps: steps)
        notifications.schedule(plan)
    }
}
