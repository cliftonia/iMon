import Foundation

/// One step of the post-hatch walkthrough: a line Dotkin "speaks" and the
/// animation it plays while saying it. Kept as data so the flow is a simple
/// list the presenter steps through.
nonisolated struct OnboardingTip: Sendable, Identifiable {
    let id: Int
    let animation: SpriteCatalog.AnimationKind
    let message: String
}

extension OnboardingTip {

    /// The full first-run walkthrough, in order. Dotkin narrates each tip and
    /// acts it out (eating, walking, attacking…) so the lesson is shown, not
    /// just told. Covers the core loops: care, activity, growth, environment.
    static let walkthrough: [OnboardingTip] = [
        OnboardingTip(
            id: 0, animation: .happy,
            message: "Hi! I'm Dotkin. Look after me and I'll grow!"
        ),
        OnboardingTip(
            id: 1, animation: .eat,
            message: "Feed me meat to fill up, vitamins for strength."
        ),
        OnboardingTip(
            id: 2, animation: .idle,
            message: "Clean my mess, and heal me when I'm sick."
        ),
        OnboardingTip(
            id: 3, animation: .sideWalk,
            message: "Your real steps grow me. Walk daily!"
        ),
        OnboardingTip(
            id: 4, animation: .attack,
            message: "Train and battle to grow stronger."
        ),
        OnboardingTip(
            id: 5, animation: .happy,
            message: "Care well and stay active to evolve me!"
        ),
        OnboardingTip(
            id: 6, animation: .sleep,
            message: "I follow real weather. Lights off to sleep."
        ),
        OnboardingTip(
            id: 7, animation: .happy,
            message: "That's it. Let's begin!"
        )
    ]
}
