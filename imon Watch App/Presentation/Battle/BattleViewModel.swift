import Foundation
import Observation

/// Display state for the battle screen: the active `BattlePhase`, both
/// species, both health pools, and the last round's outcome. Held as one
/// `@Observable` class so each mutation republishes to the view.
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

    /// The stages of a battle: intros, the move choice, each side's attack and
    /// projectile, then `victory` or `defeat`. `phase` is non-optional — a
    /// battle is always in exactly one stage.
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
