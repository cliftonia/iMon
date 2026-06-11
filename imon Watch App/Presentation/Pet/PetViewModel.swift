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

    /// Day / night / inside — drives the LCD scene (sun, night sky, or room).
    var dayPhase: DayPhase = .day

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

    // MARK: - Refusal

    /// A head-shake "no" — plays in the normal scene, not a clean action scene.
    var isRefusing: Bool = false

    /// The action ceremonies that play in their own clean scene.
    var isInActionScene: Bool {
        isInFeedingMode || isCleaningAnimation || isHealingAnimation
    }

    /// True when any ceremony, refusal or mode is active (blocks input).
    var isBusy: Bool {
        isInActionScene || isRefusing
            || screenMode == .training || screenMode == .battle
    }

    // MARK: - Evolution

    var showEvolution: Bool = false
    var evolutionTarget: PetSpecies?

    // MARK: - Error

    var error: ErrorViewConfiguration?
}
