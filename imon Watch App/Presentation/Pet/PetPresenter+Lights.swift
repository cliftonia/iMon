import Foundation
import WatchKit

// MARK: - Lights

extension PetPresenter {

    func lightsAction() {
        let (newState, result) = LightsAction.apply(
            to: state, night: currentlyNight
        )
        guard result == .toggled else {
            // Refused — by day the light must stay on.
            WKInterfaceDevice.rejectHaptic()
            return
        }
        state = newState
        updateViewModel()
        updateAnimation()
        save()
    }
}
