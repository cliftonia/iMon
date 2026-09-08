import Foundation

// MARK: - Lights

extension PetPresenter {

    func lightsAction() {
        let (newState, result) = LightsAction.apply(
            to: state, night: currentlyNight, at: .now
        )
        guard result == .toggled else {
            // By day the light is forced on — refuse like every other blocked action.
            refuse()
            return
        }
        state = newState
        updateViewModel()
        updateAnimation()
        save()
        scheduleSleepSettle()
    }

    /// Re-runs `environmentDidChange` once the settle delay passes, so the
    /// pet falls asleep without waiting for the next tick. Calling again
    /// cancels the pending run. Does nothing while the light is on or the
    /// pet is already asleep.
    private func scheduleSleepSettle() {
        sleepToggleTask?.cancel()
        sleepToggleTask = nil
        guard state.timestamps.lightsOffAt != nil, !state.isSleeping else { return }
        sleepToggleTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(TimeConstants.sleepDelay))
            guard !Task.isCancelled else { return }
            self?.environmentDidChange()
        }
    }
}
