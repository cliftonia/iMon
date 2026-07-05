import Foundation
import os

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
        complications: ComplicationReloader,
        steps: Int?,
        now: Date = .now
    ) {
        // A transient decode failure must not break the wake chain — re-arm and
        // bail. A genuine absence of a saved pet (hatching) is a true no-op.
        let loaded: PetState?
        do {
            loaded = try store.load()
        } catch {
            Log.background.error("Background load failed: \(error, privacy: .public)")
            refresh.scheduleNext(from: now)
            return
        }
        guard let state = loaded else { return }

        var advanced = GameEngine.advance(state, to: now, isNight: nil, steps: steps)

        // Evolution otherwise only happens in the foreground; evaluate it here so a
        // pet can grow while the owner is away, and announce it with a notification.
        if let target = EvolutionEngine.checkEvolution(for: advanced) {
            advanced = EvolutionEngine.evolve(advanced, to: target, at: now)
            notifications.notify(
                target.displayName, "evolved into a \(target.displayName)!", target
            )
        }

        do {
            try store.save(advanced)
        } catch {
            Log.background.error("Background save failed: \(error, privacy: .public)")
        }

        // Re-arm the next wake before the caller completes the task, so the loop
        // keeps going even if the work below is later cut short.
        refresh.scheduleNext(from: now)

        let plan = CareNotificationPlanner.plan(for: advanced, now: now, steps: steps)
        notifications.schedule(plan)

        // Refresh the watch-face complication against the same advanced state,
        // so the background wake and the foreground path bundle identically.
        ComplicationStore.save(ComplicationTimeline.entries(for: advanced, from: now))
        complications.reload()
    }
}
