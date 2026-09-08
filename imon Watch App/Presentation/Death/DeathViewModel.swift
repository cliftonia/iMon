import Foundation
import Observation

/// Screen state for the Death screen: the species name and the age in days.
///
/// A plain `@Observable` holder with no behaviour beyond the two stored values.
@Observable
final class DeathViewModel {
    var speciesName: String = ""
    var ageDays: Int = 0
}
