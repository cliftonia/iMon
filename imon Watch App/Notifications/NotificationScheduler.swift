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

extension NotificationScheduler {

    static func live(now: @escaping @Sendable () -> Date = { Date() }) -> NotificationScheduler {
        NotificationScheduler(
            schedule: { notifications in
                let center = UNUserNotificationCenter.current()
                center.removeAllPendingNotificationRequests()
                for notification in notifications {
                    let content = UNMutableNotificationContent()
                    content.title = notification.title
                    content.body = notification.body
                    content.sound = .default
                    if let sprite = NotificationSpriteRenderer.attachment(for: notification.species) {
                        content.attachments = [sprite]
                    }

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
                let content = UNMutableNotificationContent()
                content.title = title
                content.body = body
                content.sound = .default
                if let sprite = NotificationSpriteRenderer.attachment(for: species) {
                    content.attachments = [sprite]
                }
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
