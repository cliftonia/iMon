import Foundation
import Observation

@Observable
final class OnboardingViewModel {

    /// The tip currently on screen.
    var index: Int = 0

    let tips: [OnboardingTip]

    init(tips: [OnboardingTip] = OnboardingTip.walkthrough) {
        self.tips = tips
    }

    var currentTip: OnboardingTip { tips[index] }

    var isLastStep: Bool { index >= tips.count - 1 }
}
