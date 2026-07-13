import Foundation

/// The app's side of the complication hand-off: writes the baked timeline to the
/// App Group for the widget to read. The widget deliberately shares no source with
/// the app — it reads the JSON via its own mirror (`WidgetEntry` and hardcoded
/// constants in `SkykinComplication/ComplicationProvider.swift`), which must be
/// kept in lock-step with `ComplicationEntry` and the key here.
nonisolated enum ComplicationStore {

    private static let key = "com.cliftonia.imon.complicationTimeline"

    static func save(
        _ entries: [ComplicationEntry],
        to defaults: UserDefaults = .skykinShared
    ) {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        defaults.set(data, forKey: key)
    }

    static func load(
        from defaults: UserDefaults = .skykinShared
    ) -> [ComplicationEntry] {
        guard let data = defaults.data(forKey: key),
              let entries = try? JSONDecoder().decode([ComplicationEntry].self, from: data)
        else {
            return []
        }
        return entries
    }
}
