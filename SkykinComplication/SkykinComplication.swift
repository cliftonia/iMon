import WidgetKit
import SwiftUI

/// The complication extension's entry point — watchOS discovers the widget
/// through this bundle.
@main
struct SkykinComplicationBundle: WidgetBundle {
    var body: some Widget {
        SkykinComplication()
    }
}

/// The watch-face complication. Renders the timeline the app bakes into the
/// shared App Group, so the face shows the saved pet without the widget
/// process ever running the engine — see `ComplicationProvider`.
struct SkykinComplication: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "SkykinComplication", provider: ComplicationProvider()) { entry in
            ComplicationView(entry: entry)
                .containerBackground(.clear, for: .widget)
        }
        .configurationDisplayName("Skykin")
        .description("Your pet at a glance.")
        .supportedFamilies([
            .accessoryCircular, .accessoryRectangular, .accessoryInline, .accessoryCorner
        ])
    }
}
