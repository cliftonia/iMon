import Foundation
import Observation

/// The Settings screen's presenter. Toggles bind straight to the shared
/// `SettingsStore` (itself observable); the debug actions (DEBUG only) are
/// injected closures onto the app's presenters, so this stays free of
/// navigation and game knowledge. Holds no ViewModel — everything it exposes
/// is immutable or already observable.
final class SettingsPresenter {

    let settings: SettingsStore

    /// "1.0 (1)" from the bundle, "—" for missing values; shown on the About row.
    var versionLabel: String {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "—"
        let build = info?["CFBundleVersion"] as? String ?? "—"
        return "\(version) (\(build))"
    }

    #if DEBUG
    let debug: SettingsDebugActions

    /// Creates the presenter for the Settings screen, with the developer
    /// actions shown in its Debug section.
    init(settings: SettingsStore, debug: SettingsDebugActions) {
        self.settings = settings
        self.debug = debug
    }
    #else
    /// Creates the presenter for the Settings screen.
    init(settings: SettingsStore) {
        self.settings = settings
    }
    #endif
}

#if DEBUG
/// The developer-only actions under the Settings screen's Debug section,
/// injected as a witness so `SettingsPresenter` holds no game knowledge.
@MainActor
struct SettingsDebugActions {
    let setWeather: (WeatherIconCondition?) -> Void
    let forceEvolve: () -> Void
    let careTest: () -> Void
    let killPet: () -> Void
    let morph: (PetSpecies) -> Void
}
#endif
