import Foundation
import WatchKit

// MARK: - Lights & Sleep Toggle

extension PetPresenter {

    func lightsAction() {
        guard LightsAction.canToggle(state) else {
            WKInterfaceDevice.rejectHaptic()
            return
        }
        sleepToggleTask?.cancel()
        sleepToggleTask = nil

        let (newState, result) = LightsAction.apply(to: state, at: .now)
        state = newState
        updateViewModel()
        updateAnimation()
        save()

        if result == .toggledDuringSleep {
            scheduleSleepToggleResolution()
        }
    }

    private func scheduleSleepToggleResolution() {
        sleepToggleTask = Task { [weak self] in
            try? await Task.sleep(
                for: .seconds(TimeConstants.lightsToggleSleepDelay)
            )
            guard !Task.isCancelled else { return }
            self?.resolveSleepToggle()
        }
    }

    private func resolveSleepToggle() {
        guard state.timestamps.lightsToggledDuringSleepAt != nil else {
            return
        }
        if state.lightsOn {
            state.isSleeping = false
        } else {
            state.isSleeping = true
            state.timestamps.lightsToggledDuringSleepAt = nil
        }
        updateViewModel()
        updateAnimation()
        save()
    }
}
