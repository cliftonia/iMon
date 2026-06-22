import WidgetKit
import SwiftUI

// Placeholder complication so the extension produces an executable and the app
// installs. The real provider + family views are added once the shared kernel
// (ComplicationEntry / ComplicationStore / AppGroup) is a member of this target
// and the App Group capability is enabled.

@main
struct SkykinComplicationBundle: WidgetBundle {
    var body: some Widget {
        SkykinComplication()
    }
}

struct SkykinComplication: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "SkykinComplication", provider: PlaceholderProvider()) { _ in
            Text("Skykin")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .containerBackground(.clear, for: .widget)
        }
        .configurationDisplayName("Skykin")
        .description("Your pet at a glance.")
        .supportedFamilies([
            .accessoryCircular, .accessoryRectangular, .accessoryInline, .accessoryCorner
        ])
    }
}

struct PlaceholderEntry: TimelineEntry {
    let date: Date
}

struct PlaceholderProvider: TimelineProvider {
    func placeholder(in context: Context) -> PlaceholderEntry {
        PlaceholderEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (PlaceholderEntry) -> Void) {
        completion(PlaceholderEntry(date: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PlaceholderEntry>) -> Void) {
        completion(Timeline(entries: [PlaceholderEntry(date: Date())], policy: .never))
    }
}
