import WatchKit

extension WKInterfaceDevice {

    static func feedHaptic() {
        WKInterfaceDevice.current().play(.click)
    }

    static func chompHaptic() {
        WKInterfaceDevice.current().play(.directionDown)
    }

    static func rejectHaptic() {
        WKInterfaceDevice.current().play(.failure)
    }

    static func cleanHaptic() {
        WKInterfaceDevice.current().play(.success)
    }

    static func healHaptic() {
        WKInterfaceDevice.current().play(.success)
    }

    static func evolveHaptic() {
        WKInterfaceDevice.current().play(.notification)
    }

    static func battleHaptic() {
        WKInterfaceDevice.current().play(.directionUp)
    }

    static func battleWinHaptic() {
        WKInterfaceDevice.current().play(.success)
    }

    static func battleLoseHaptic() {
        WKInterfaceDevice.current().play(.failure)
    }

    static func deathHaptic() {
        WKInterfaceDevice.current().play(.failure)
    }

    static func hatchHaptic() {
        WKInterfaceDevice.current().play(.start)
    }

    static func buttonHaptic() {
        WKInterfaceDevice.current().play(.click)
    }

    static func trainingHitHaptic() {
        WKInterfaceDevice.current().play(.success)
    }

    static func trainingMissHaptic() {
        WKInterfaceDevice.current().play(.retry)
    }

    static func trainingWinHaptic() {
        WKInterfaceDevice.current().play(.notification)
    }

    static func trainingLoseHaptic() {
        WKInterfaceDevice.current().play(.failure)
    }
}
