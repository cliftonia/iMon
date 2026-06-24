import Foundation
import Observation

/// Tracks the system Low Power Mode so the UI can switch to the red battery-saver
/// palette. The low-power check is injected (witness style) so it can be mocked.
@MainActor
@Observable
final class PowerSaverStore {

    private(set) var isActive: Bool
    private let isLowPowerEnabled: @Sendable () -> Bool

    init(isLowPowerEnabled: @escaping @Sendable () -> Bool) {
        self.isLowPowerEnabled = isLowPowerEnabled
        self.isActive = isLowPowerEnabled()
    }

    /// Re-reads the system power state (called when it changes).
    func refresh() {
        isActive = isLowPowerEnabled()
    }
}

extension PowerSaverStore {
    static func live() -> PowerSaverStore {
        PowerSaverStore(
            isLowPowerEnabled: { ProcessInfo.processInfo.isLowPowerModeEnabled }
        )
    }
}
