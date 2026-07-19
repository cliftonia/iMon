import WatchKit

/// Named haptic cues, one per game event, so the `WKHapticType` mapping and
/// the master switch live in one place.
extension WKInterfaceDevice {

    /// Master switch for every haptic, mirrored from the Settings toggle. When
    /// off, all the cues below become no-ops so buttons and actions stay silent.
    static var hapticsEnabled = true

    private static func perform(_ type: WKHapticType) {
        guard hapticsEnabled else { return }
        WKInterfaceDevice.current().play(type)
    }

    static func feedHaptic() { perform(.click) }

    static func chompHaptic() { perform(.directionDown) }

    static func rejectHaptic() { perform(.failure) }

    static func cleanHaptic() { perform(.success) }

    static func healHaptic() { perform(.success) }

    static func evolveHaptic() { perform(.notification) }

    static func battleHaptic() { perform(.directionUp) }

    static func battleWinHaptic() { perform(.success) }

    static func battleLoseHaptic() { perform(.failure) }

    static func hatchHaptic() { perform(.start) }

    static func buttonHaptic() { perform(.click) }

    static func trainingHitHaptic() { perform(.success) }

    static func trainingMissHaptic() { perform(.retry) }

    static func trainingWinHaptic() { perform(.notification) }

    static func trainingLoseHaptic() { perform(.failure) }
}
