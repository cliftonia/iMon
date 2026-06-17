import Foundation

nonisolated enum FeedAction {

    enum FoodKind: Sendable {
        case meat
        case vitamin
    }

    // MARK: - Query

    static func canFeed(_ state: PetState) -> Bool {
        !state.isDead && !state.isEgg && !state.isSleeping
    }

    // MARK: - Apply

    static func apply(to state: PetState, food: FoodKind, at date: Date = .now) -> PetState {
        guard canFeed(state) else { return state }

        var state = state

        switch food {
        case .meat:
            state.hungerHearts.increment(upTo: state.species.maxHunger)
            state.weight.add(TimeConstants.meatWeightGain)
        case .vitamin:
            state.strengthHearts.increment(upTo: state.species.maxStrength)
            state.weight.add(TimeConstants.vitaminWeightGain)
        }

        state.timestamps.lastFedAt = date
        return state
    }
}
