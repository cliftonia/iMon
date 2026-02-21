import Foundation
import Observation

@Observable
final class BattleViewModel {

    var phase: BattlePhase = .intro
    var petSpecies: virtual petSpecies = .emberkin
    var opponentSpecies: virtual petSpecies = .marshkin
    var result: BattleResult?

    enum BattlePhase: Sendable {
        case intro
        case approach
        case clash
        case result
    }
}
