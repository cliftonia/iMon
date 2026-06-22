import WidgetKit
import SwiftUI

@main
struct SkykinComplicationBundle: WidgetBundle {
    var body: some Widget {
        SkykinComplication()
    }
}

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
