import SwiftUI
import WatchKit
import UserNotifications
import os

@main
struct imon_Watch_AppApp: App {

    @WKApplicationDelegateAdaptor private var appDelegate: AppDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

final class AppDelegate: NSObject, WKApplicationDelegate {

    func applicationDidFinishLaunching() {
        Log.presentation.info("Skykin launched")
        UNUserNotificationCenter.current().delegate = self
        Task { await StepCountProvider.requestAuthorization() }
        Task { _ = await NotificationScheduler.live().requestAuthorization() }
    }

    func applicationDidBecomeActive() {
        Log.presentation.debug("App became active")
    }

    func applicationWillResignActive() {
        Log.presentation.debug("App will resign active")
        // Always leave one refresh pending when heading to the background, so a
        // throttled or failed wake doesn't break the chain.
        BackgroundRefreshScheduler.live().schedule(
            Date().addingTimeInterval(TimeConstants.backgroundRefreshInterval)
        )
    }

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        for task in backgroundTasks {
            switch task {
            case let refresh as WKApplicationRefreshBackgroundTask:
                handleRefresh(refresh)
            case let snapshot as WKSnapshotRefreshBackgroundTask:
                snapshot.setTaskCompleted(
                    restoredDefaultState: true,
                    estimatedSnapshotExpiration: .distantFuture,
                    userInfo: nil
                )
            default:
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }

    /// Advances the pet, replans reminders, re-arms the next wake, then completes.
    private func handleRefresh(_ task: WKApplicationRefreshBackgroundTask) {
        Task { @MainActor in
            let steps = try? await StepCountProvider.live().fetchTodaySteps()
            let store = JSONPetStateStore.live()
            BackgroundTick.perform(
                store: store,
                notifications: .live(),
                refresh: .live(),
                steps: steps,
                now: Date()
            )
            if let state = try? store.load() {
                ComplicationStore.save(
                    ComplicationTimeline.entries(for: state, from: Date())
                )
            }
            ComplicationReloader.live.reload()
            task.setTaskCompletedWithSnapshot(false)
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    /// Show care reminders even while the app is in the foreground — otherwise
    /// watchOS silently drops them when the screen is on the app.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound, .list]
    }
}
