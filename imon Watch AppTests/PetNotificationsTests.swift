import Testing
import Foundation
@testable import imon_Watch_App

@Suite("Care notifications wiring")
@MainActor
struct PetNotificationsTests {

    /// Synchronous capture box — the scheduler closures fire on the main actor
    /// within the call, so plain reference storage is safe.
    private final class Capture: @unchecked Sendable {
        var scheduled: [CareNotification]?
    }

    private func makePresenter(_ state: PetState, _ capture: Capture) -> PetPresenter {
        let store = PetStateStore(save: { _ in }, load: { nil }, delete: {})
        let presenter = PetPresenter(state: state, store: store)
        presenter.notificationScheduler = NotificationScheduler(
            schedule: { capture.scheduled = $0 },
            cancelAll: {},
            requestAuthorization: { true }
        )
        return presenter
    }

    private func today(at hour: Int) -> Date {
        let calendar = Calendar.current
        let midnight = calendar.startOfDay(for: Date(timeIntervalSince1970: 1_700_000_000))
        return calendar.date(byAdding: .hour, value: hour, to: midnight) ?? midnight
    }

    @Test
    func `scheduling feeds the planned reminders to the scheduler`() {
        let now = today(at: 8)
        let state = makeTestState(species: .emberkin, hunger: 2, at: now)
        let capture = Capture()
        let presenter = makePresenter(state, capture)

        presenter.scheduleCareNotifications(now: now)

        let expected = CareNotificationPlanner.plan(for: state, now: now, steps: nil)
        #expect(capture.scheduled == expected)
        #expect(expected.isEmpty == false)
    }

    @Test
    func `scheduling also refreshes the complication`() {
        let reloads = ReloadBox()
        let presenter = makePresenter(makeTestState(), Capture())
        presenter.complicationReloader = ComplicationReloader(reload: { reloads.count += 1 })

        presenter.scheduleCareNotifications(now: .now)

        #expect(reloads.count == 1)
    }

    private final class ReloadBox: @unchecked Sendable {
        var count = 0
    }
}
