import Foundation
import Observation

@Observable
final class OnboardingViewModel {

    var index: Int = 0

    let tips: [OnboardingTip] = OnboardingTip.walkthrough

    var currentTip: OnboardingTip { tips[index] }

    var isLastStep: Bool { index >= tips.count - 1 }
}
