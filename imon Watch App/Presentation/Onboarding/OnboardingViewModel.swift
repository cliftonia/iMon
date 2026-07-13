import Foundation
import Observation

@Observable
final class OnboardingViewModel {

    /// The tip currently on screen.
    var index: Int = 0

    let tips: [OnboardingTip] = OnboardingTip.walkthrough

    var currentTip: OnboardingTip { tips[index] }

    var isLastStep: Bool { index >= tips.count - 1 }
}
