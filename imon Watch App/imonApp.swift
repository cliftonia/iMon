import SwiftUI
import WatchKit
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
            BackgroundTick.perform(
                store: JSONPetStateStore.live(),
                notifications: .live(),
                refresh: .live(),
                steps: steps,
                now: Date()
            )
            ComplicationReloader.live.reload()
            task.setTaskCompletedWithSnapshot(false)
        }
    }
}
