import Foundation
import os

/// The work performed on a background wake: advance the saved pet to `now`,
/// persist it, re-arm the next wake, and re-evaluate the care reminders against
/// the fresh state. Self-contained — it reads and writes the store directly, so
/// it runs on a bare background launch with no SwiftUI scene. Reuses the existing
/// engine and the care-notification planner; it introduces no new game logic.
/// Honours the Settings toggle via `notificationsEnabled`, matching the
/// foreground contract in `PetPresenter.handleScenePhase`. `steps` is today's
/// HealthKit total, `nil` when the Steps toggle is off or the read failed —
/// the engine and planner then skip activity scaling.
nonisolated enum BackgroundTick {

    // No defaulted witnesses — a new call site must decide notifications explicitly.
    // swiftlint:disable:next function_parameter_count
    static func perform(
        store: PetStateStore,
        notifications: NotificationScheduler,
        refresh: BackgroundRefreshScheduler,
        complications: ComplicationReloader,
        notificationsEnabled: Bool,
        steps: Int?,
        now: Date = .now
    ) {
        // A load failure re-arms and bails (keep the chain); a missing pet is a true no-op.
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

        // Evolution otherwise runs only foregrounded — evaluate so pets grow while away.
        if let target = EvolutionEngine.checkEvolution(for: advanced) {
            advanced = EvolutionEngine.evolve(advanced, to: target, at: now)
            if notificationsEnabled {
                notifications.notify(
                    target.displayName, "evolved into a \(target.displayName)!", target
                )
            }
        }

        do {
            try store.save(advanced)
        } catch {
            Log.background.error("Background save failed: \(error, privacy: .public)")
        }

        // Re-arm before the task completes — the chain survives if work below is cut short.
        refresh.scheduleNext(from: now)

        // Toggle off: a wake must not re-arm reminders — clear any left pending instead.
        if notificationsEnabled {
            let plan = CareNotificationPlanner.plan(for: advanced, now: now, steps: steps)
            notifications.schedule(plan)
        } else {
            notifications.cancelAll()
        }

        // Rebuild against the same advanced state — background and foreground must match.
        ComplicationStore.save(ComplicationTimeline.entries(for: advanced, from: now))
        complications.reload()
    }
}
