import Foundation
import Observation

/// Screen state for the Death screen: the species name and the age in days.
///
/// A plain `@Observable` holder with no behaviour beyond the two stored values.
@Observable
final class DeathViewModel {
    /// The species name shown on the Death screen.
    var speciesName: String = ""
    /// The age in days shown on the Death screen.
    var ageDays: Int = 0
}
