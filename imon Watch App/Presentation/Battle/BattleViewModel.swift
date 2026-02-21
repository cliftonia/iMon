import Foundation
import Observation

@Observable
final class BattleViewModel {

    var phase: BattlePhase = .intro
    var petSpecies: DigimonSpecies = .agumon
    var opponentSpecies: DigimonSpecies = .betamon
    var result: BattleResult?

    enum BattlePhase: Sendable {
        case intro
        case approach
        case clash
        case result
    }
}
