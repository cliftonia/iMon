import WidgetKit
import Foundation

/// The widget's view of one timeline snapshot. A deliberate mirror of the app's
/// `ComplicationEntry`, kept here so the widget shares no source with the app —
/// the contract is the JSON the app writes to the App Group. Decodes only the
/// subset of `ComplicationEntry`'s keys the views render; `JSONDecoder` ignores
/// the extra keys the app writes.
struct WidgetEntry: TimelineEntry, Codable {
    let date: Date
    let speciesName: String
    let spriteRows: [UInt16]
    let hungerValue: Int
    let hungerMax: Int
    let needsAttention: Bool
    let statusText: String
}

extension WidgetEntry {
    static let placeholder = WidgetEntry(
        date: Date(),
        speciesName: "Skykin",
        spriteRows: [UInt16](repeating: 0, count: 16),
        hungerValue: 2,
        hungerMax: 4,
        needsAttention: false,
        statusText: "happy"
    )
}

/// Reads the baked timeline the app writes to the App Group. No engine here —
/// the app does all the simulation and bakes the result, including the sprite.
struct ComplicationProvider: TimelineProvider {

    // Must match `AppGroup.identifier` and `ComplicationStore.key` in the app.
    private static let appGroup = "group.cliftonia.skykin"
    private static let timelineKey = "com.cliftonia.imon.complicationTimeline"

    func placeholder(in context: Context) -> WidgetEntry { .placeholder }

    func getSnapshot(in context: Context, completion: @escaping (WidgetEntry) -> Void) {
        completion(loadEntries().first ?? .placeholder)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WidgetEntry>) -> Void) {
        let entries = loadEntries()
        let last = entries.last ?? .placeholder
        let next = last.date.addingTimeInterval(3_600)
        completion(Timeline(entries: entries, policy: .after(next)))
    }

    private func loadEntries() -> [WidgetEntry] {
        guard let defaults = UserDefaults(suiteName: Self.appGroup),
              let data = defaults.data(forKey: Self.timelineKey),
              let entries = try? JSONDecoder().decode([WidgetEntry].self, from: data),
              !entries.isEmpty
        else {
            return [.placeholder]
        }
        return entries
    }
}
