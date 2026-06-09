import Foundation
import Observation

@Observable
final class BattleViewModel {

    var phase: BattlePhase = .introPet
    var petSpecies: PetSpecies = .emberkin
    var opponentSpecies: PetSpecies = .marshkin
    var petHP: Int = 3
    var petMaxHP: Int = 3
    var opponentHP: Int = 3
    var opponentMaxHP: Int = 3
    var result: BattleResult?
    var lastRoundOutcome: RoundOutcome?
    var lightsOn: Bool = true

    enum BattlePhase: Sendable {
        case introPet
        case introVS
        case introEnemy
        case choosing
        case attacking
        case projectile
        case opponentAttacking
        case opponentProjectile
        case impact
        case victory
        case defeat
    }
}
