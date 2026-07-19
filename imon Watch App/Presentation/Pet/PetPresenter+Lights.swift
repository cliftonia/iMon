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

    /// After the light goes off at night the pet only drifts off once the
    /// settle delay passes — re-advance then so it sleeps without waiting for
    /// the next game tick.
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
