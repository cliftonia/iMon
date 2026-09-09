import Foundation
import Observation

/// Display state for the onboarding walkthrough, holding the current step.
///
/// An observable class so the view redraws as `index` advances through
/// `OnboardingTip.walkthrough`.
@Observable
final class OnboardingViewModel {

    /// The step currently on screen, as a zero-based subscript into `tips`.
    var index: Int = 0

    /// The walkthrough steps, in display order, from `OnboardingTip.walkthrough`.
    let tips: [OnboardingTip] = OnboardingTip.walkthrough

    var currentTip: OnboardingTip { tips[index] }

    var isLastStep: Bool { index >= tips.count - 1 }
}
