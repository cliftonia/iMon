import Foundation
import Observation

@Observable
final class PetViewModel {

    // MARK: - Screen Mode

    enum ScreenMode {
        case normal
        case training
        case battle
    }

    var screenMode: ScreenMode = .normal

    // MARK: - Pet Display

    var status: PetStatus?
    var currentAnimation: SpriteCatalog.AnimationKind = .idle
    var petOffsetX: Int = 8

    // MARK: - Menu

    enum MenuAction: Int, CaseIterable {
        case stats = 0
        case feed
        case train
        case battle
        case clean
        case lights
        case heal
        case call
    }

    var menuSelection: MenuAction = .stats

    // MARK: - Feeding

    enum FeedingPhase: Equatable {
        case inactive
        case selecting
        case serving
        case bite(Int)
        case satisfied
    }

    var feedingPhase: FeedingPhase = .inactive
    var selectedFood: FeedAction.FoodKind = .meat

    var isInFeedingMode: Bool {
        feedingPhase != .inactive
    }

    // MARK: - Cleaning

    var isCleaningAnimation: Bool = false

    // MARK: - Healing

    var isHealingAnimation: Bool = false

    /// True when any LCD ceremony or inline mode is active.
    var isBusy: Bool {
        isInFeedingMode || isCleaningAnimation
            || isHealingAnimation
            || screenMode == .training || screenMode == .battle
    }

    // MARK: - Evolution

    var showEvolution: Bool = false
    var evolutionTarget: DigimonSpecies?

    // MARK: - Error

    var error: ErrorViewConfiguration?
}
