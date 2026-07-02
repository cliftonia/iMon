import Foundation
import UserNotifications

/// Side-effecting wrapper around the user-notification centre, injected as a
/// protocol witness so presenters can be tested with a capturing mock.
nonisolated struct NotificationScheduler: Sendable {
    /// Replaces every pending care reminder with the supplied set.
    let schedule: @Sendable ([CareNotification]) -> Void
    /// Fires a one-off notification immediately (e.g. an evolution announcement).
    let notify: @Sendable (_ title: String, _ body: String, _ species: PetSpecies) -> Void
    let cancelAll: @Sendable () -> Void
    let requestAuthorization: @Sendable () async -> Bool
}

nonisolated extension NotificationScheduler {

    /// Builds a reminder's content, attaching the pet's home-scene sprite for the
    /// sky at `fireDate` (the moment it shows). Shared by scheduled and one-off sends.
    private static func makeContent(
        title: String, body: String, species: PetSpecies, fireDate: Date
    ) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        let isNight = SleepSchedule.isNight(weatherNight: nil, at: fireDate)
        if let sprite = NotificationSpriteRenderer.attachment(for: species, isNight: isNight) {
            content.attachments = [sprite]
        }
        return content
    }

    static func live(now: @escaping @Sendable () -> Date = { Date() }) -> NotificationScheduler {
        NotificationScheduler(
            schedule: { notifications in
                let center = UNUserNotificationCenter.current()
                center.removeAllPendingNotificationRequests()
                for notification in notifications {
                    let content = makeContent(
                        title: notification.title, body: notification.body,
                        species: notification.species, fireDate: notification.fireDate
                    )
                    let interval = max(1, notification.fireDate.timeIntervalSince(now()))
                    let trigger = UNTimeIntervalNotificationTrigger(
                        timeInterval: interval, repeats: false
                    )
                    let request = UNNotificationRequest(
                        identifier: notification.id, content: content, trigger: trigger
                    )
                    center.add(request)
                }
            },
            notify: { title, body, species in
                let content = makeContent(title: title, body: body, species: species, fireDate: now())
                let request = UNNotificationRequest(
                    identifier: "event-\(title)", content: content, trigger: nil
                )
                UNUserNotificationCenter.current().add(request)
            },
            cancelAll: {
                UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            },
            requestAuthorization: {
                do {
                    return try await UNUserNotificationCenter.current()
                        .requestAuthorization(options: [.alert, .sound])
                } catch {
                    return false
                }
            }
        )
    }

    // AUDIT 2026-06-24: unused — tests build witnesses inline. Kept as DI scaffolding.
    static let mock = NotificationScheduler(
        schedule: { _ in },
        notify: { _, _, _ in },
        cancelAll: {},
        requestAuthorization: { true }
    )
}
