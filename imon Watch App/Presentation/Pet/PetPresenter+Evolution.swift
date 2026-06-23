import Foundation
import WatchKit
import UserNotifications

// MARK: - Evolution

extension PetPresenter {

    /// Offers a step-gated evolution when the lifetime accumulator has crossed
    /// the stage threshold and the pet is idle. Care state picks the branch.
    func checkEvolution() {
        guard !viewModel.isBusy, !viewModel.showEvolution else { return }
        guard let target = EvolutionEngine.checkEvolution(for: state) else { return }
        viewModel.showEvolution = true
        viewModel.evolutionTarget = target
    }

    func applyEvolution() {
        guard let target = viewModel.evolutionTarget else {
            return
        }
        state = EvolutionEngine.evolve(state, to: target, at: .now)
        if debugStepIndex > 0 {
            state.poopCount = 1
            state.isInjured = true
        }
        viewModel.showEvolution = false
        viewModel.evolutionTarget = nil
        updateViewModel()
        updateAnimation()
        save()
        WKInterfaceDevice.evolveHaptic()
    }
}

// MARK: - Debug Evolution

extension PetPresenter {

    /// Debug: walk through each evolution journey, resetting
    /// to egg between them. Loops back to journey 1 at the end.
    private static let debugJourneys: [[PetSpecies]] = [
        [.dotkin, .hopkin, .emberkin, .rexkin, .steelkin],
        [.dotkin, .hopkin, .marshkin, .blazekin, .orbkin],
        [.dotkin, .hopkin, .emberkin, .dreadkin, .steelkin],
        [.dotkin, .hopkin, .emberkin, .pyrekin, .orbkin],
        [.dotkin, .hopkin, .marshkin, .galekin, .steelkin],
        [.dotkin, .hopkin, .marshkin, .tidekin, .orbkin],
        [.dotkin, .hopkin, .emberkin, .sludgekin, .plushkin]
    ]

    private static let debugJourneyKey = "debugJourneyIndex"

    private var debugJourneyIndex: Int {
        get { UserDefaults.standard.integer(forKey: Self.debugJourneyKey) }
        set { UserDefaults.standard.set(newValue, forKey: Self.debugJourneyKey) }
    }

    func debugEvolve() {
        guard !viewModel.isBusy else { return }

        let journeys = Self.debugJourneys
        let journey = journeys[debugJourneyIndex]

        let nextStep = debugStepIndex + 1
        if nextStep >= journey.count {
            state.isDead = true
            let next = debugJourneyIndex + 1
            debugJourneyIndex = next >= journeys.count ? 0 : next
            debugStepIndex = 0
            updateViewModel()
            save()
        } else {
            let target = journey[nextStep]
            debugStepIndex = nextStep
            viewModel.showEvolution = true
            viewModel.evolutionTarget = target
        }
    }

    /// Debug: drain the pet so it visibly needs care (screen + complication flip
    /// to "hungry"), then fire a real care reminder ~12s out to verify on-device
    /// notification delivery. Lower your wrist right after pressing so the banner
    /// can appear (foreground notifications are suppressed).
    func debugCareTest() {
        guard !viewModel.isBusy else { return }
        viewModel.debugNotice = "checking…"
        Task { @MainActor [weak self] in
            guard let self else { return }
            let center = UNUserNotificationCenter.current()
            var settings = await center.notificationSettings()
            // If permission was never answered, prompt for it now (the launch
            // request can be missed) so the test can actually deliver.
            if settings.authorizationStatus == .notDetermined {
                _ = try? await center.requestAuthorization(options: [.alert, .sound])
                settings = await center.notificationSettings()
            }
            self.viewModel.debugNotice = "N:" + Self.describe(settings.authorizationStatus)
            // Fire a real care reminder ~12s out so delivery can be verified.
            let reminder = CareNotification(
                kind: .hunger, fireDate: Date().addingTimeInterval(12)
            )
            self.notificationScheduler.schedule([reminder])
        }
    }

    private static func describe(_ status: UNAuthorizationStatus) -> String {
        switch status {
        case .authorized: "auth"
        case .denied: "DENIED"
        case .notDetermined: "notAsked"
        case .provisional: "provisional"
        case .ephemeral: "ephemeral"
        @unknown default: "unknown"
        }
    }
}
