import Foundation

/// The shared hand-off for the complication: the app writes the baked timeline to
/// the App Group; the widget reads it. Shared between both targets (with
/// `ComplicationEntry` and `AppGroup`), so they agree on the format and location.
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
