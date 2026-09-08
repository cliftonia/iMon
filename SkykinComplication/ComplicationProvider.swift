import WidgetKit
import Foundation

/// The complication's view of one timeline snapshot. A deliberate mirror of the
/// app's `ComplicationEntry`, kept here so the extension shares no source with
/// the app — the contract is the JSON the app writes to the App Group. Decodes
/// only the subset of `ComplicationEntry`'s keys the views render; `JSONDecoder`
/// ignores the extra keys the app writes.
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
    /// The newborn's idle pose (a copy of the app's Dotkin frame — the extension
    /// shares no source with the app), so the gallery preview and a fresh install
    /// show a creature rather than an empty box.
    static let placeholder = WidgetEntry(
        date: Date(),
        speciesName: "Dotkin",
        spriteRows: [
            0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
            0x03C0, 0x0FF0, 0x1FF8, 0x37B8, 0x3FF8, 0x3C78, 0x1FF8, 0x0FF0, 0x03C0,
            0x0000
        ],
        hungerValue: 2,
        hungerMax: 4,
        needsAttention: false,
        statusText: "happy"
    )
}

/// The complication's timeline provider. Reads the baked timeline the app
/// writes to the App Group — no engine here: the app does all the simulation
/// and bakes the result, including the sprite.
struct ComplicationProvider: TimelineProvider {

    // Must match `AppGroup.identifier` and `ComplicationStore.key` in the app.
    private static let appGroup = "group.cliftonia.skykin"
    private static let timelineKey = "com.cliftonia.imon.complicationTimeline"

    /// Returns `WidgetEntry.placeholder`, the newborn pose shown before the app
    /// has baked any timeline.
    func placeholder(in context: Context) -> WidgetEntry { .placeholder }

    /// Answers with the first baked entry, or the placeholder when the App
    /// Group holds nothing readable.
    func getSnapshot(in context: Context, completion: @escaping (WidgetEntry) -> Void) {
        completion(loadEntries().first ?? .placeholder)
    }

    /// Answers with the baked entries and asks WidgetKit to reload one hour
    /// after the last entry's date; an unreadable App Group yields a one-entry
    /// timeline of the placeholder.
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
