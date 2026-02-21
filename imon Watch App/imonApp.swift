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
        Log.presentation.info("imon launched")
    }

    func applicationDidBecomeActive() {
        Log.presentation.debug("App became active")
    }

    func applicationWillResignActive() {
        Log.presentation.debug("App will resign active")
    }
}
