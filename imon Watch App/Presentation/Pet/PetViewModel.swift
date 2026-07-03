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
    var petOffsetX: Int = 8

    /// Progress toward the next evolution (0...1) — drives the bezel ring.
    var evolutionProgress: Double = 0

    // MARK: - Menu

    enum MenuAction: Int, CaseIterable {
        case stats = 0
        case feed
        case train
        case battle
        case clean
        case lights
        case heal
        case settings
    }

    var menuSelection: MenuAction = .stats

    // MARK: - Activity

    /// The steps of the feeding ceremony.
    enum FeedingPhase: Equatable {
        case selecting
        case serving
        case bite(Int)
        case satisfied
    }

    /// What the pet is actively doing — the single source of truth for input
    /// blocking, the LCD scene and the animation. A refusal is its own case
    /// because it plays in the normal scene rather than a clean action booth.
    enum Activity: Equatable {
        case idle
        case feeding(FeedingPhase)
        case cleaning
        case healing
        case refusing
    }

    var activity: Activity = .idle
    var selectedFood: FeedAction.FoodKind = .meat

    /// The feeding sub-phase, when feeding — for the buttons and animation.
    var feedingPhase: FeedingPhase? {
        if case .feeding(let phase) = activity { return phase }
        return nil
    }

    var isInFeedingMode: Bool { feedingPhase != nil }

    /// The ceremonies that play in their own clean scene (a refusal does not).
    var isInActionScene: Bool {
        switch activity {
        case .feeding, .cleaning, .healing: return true
        case .idle, .refusing: return false
        }
    }

    /// True when any activity or mode is active (blocks input).
    var isBusy: Bool {
        activity != .idle
            || screenMode == .training || screenMode == .battle
    }

    // MARK: - Evolution

    var showEvolution: Bool = false
    var evolutionTarget: PetSpecies?

    // MARK: - Debug

    /// A short on-screen diagnostic shown in the debug row (e.g. notification
    /// permission status after the care-test long-press).
    var debugNotice: String = ""
}
