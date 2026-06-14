import Foundation
import UserNotifications

nonisolated enum PetNotificationScheduler {
    static func scheduleHungerReminder(at date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Skykin"
        content.body = "Your Creature is hungry!"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: max(1, date.timeIntervalSinceNow),
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: "hunger",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    static func schedulePoopReminder(at date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Skykin"
        content.body = "Your Creature made a mess!"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: max(1, date.timeIntervalSinceNow),
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: "poop",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    static func scheduleInjuryReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Skykin"
        content.body = "Your Creature is injured! Heal it soon!"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 60,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: "injury",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    static func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    static func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound])
        } catch {
            return false
        }
    }
}
