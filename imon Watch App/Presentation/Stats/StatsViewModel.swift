import Foundation
import Observation

@Observable
final class StatsViewModel {
    var speciesName: String = ""
    var stageName: String = ""
    var ageDays: Int = 0
    var weightGrams: Int = 0
    var hungerHearts: Int = 0
    var strengthHearts: Int = 0
    var battleWins: Int = 0
    var battleLosses: Int = 0
    var winRate: String = "0%"
}
