import Foundation
import Observation

/// Drives the Settings screen. The toggles bind straight to the shared
/// `SettingsStore` (itself observable); the debug actions (DEBUG only) are
/// injected closures onto the app's presenters, so this stays free of
/// navigation and game knowledge. Holds no ViewModel — everything it exposes
/// is immutable or already observable.
final class SettingsPresenter {

    let settings: SettingsStore

    /// "1.0 (1)" from the bundle — shown on the About row.
    var versionLabel: String {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "—"
        let build = info?["CFBundleVersion"] as? String ?? "—"
        return "\(version) (\(build))"
    }

    #if DEBUG
    let debug: SettingsDebugActions

    init(settings: SettingsStore, debug: SettingsDebugActions) {
        self.settings = settings
        self.debug = debug
    }
    #else
    init(settings: SettingsStore) {
        self.settings = settings
    }
    #endif
}

#if DEBUG
/// The developer-only actions surfaced under the Settings page's Debug section.
@MainActor
struct SettingsDebugActions {
    let setWeather: (WeatherIconCondition?) -> Void
    let forceEvolve: () -> Void
    let careTest: () -> Void
    let killPet: () -> Void
    let morph: (PetSpecies) -> Void
}
#endif
