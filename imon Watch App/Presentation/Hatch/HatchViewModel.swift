import Foundation
import Observation

@Observable
final class HatchViewModel {

    var phase: HatchPhase = .egg

    enum HatchPhase: Sendable {
        case egg
        case cracking
        case hatched
    }
}
