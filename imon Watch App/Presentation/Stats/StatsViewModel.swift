import Foundation
import Observation

@Observable
final class StatsViewModel {
    var speciesName: String = ""
    var stageName: String = ""
    var ageDays: Int = 0
    var weightGrams: Int = 0
    var hungerHearts: Int = 0
    var maxHunger: Int = 4
    var strengthHearts: Int = 0
    var maxStrength: Int = 4
    var battleHP: Int = 0
    var battleWins: Int = 0
    var battleLosses: Int = 0
    var winRate: String = "0%"
    var activityLabel: String = "—"
    var totalSteps: String = "0"
    var evolveProgress: String = "—"
}
