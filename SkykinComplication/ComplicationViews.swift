import SwiftUI
import WidgetKit

/// Renders a 16×16 sprite (one `UInt16` per row, MSB = leftmost) baked into the
/// entry by the app, so the complication needs none of the app's sprite stack.
struct SpriteCanvas: View {
    let rows: [UInt16]

    var body: some View {
        Canvas { context, size in
            let side = min(size.width, size.height)
            let pixel = side / 16
            for y in 0..<16 {
                let row = y < rows.count ? rows[y] : 0
                for x in 0..<16 where (row >> (15 - x)) & 1 == 1 {
                    let rect = CGRect(
                        x: CGFloat(x) * pixel,
                        y: CGFloat(y) * pixel,
                        width: pixel + 0.5,
                        height: pixel + 0.5
                    )
                    context.fill(Path(rect), with: .color(.primary))
                }
            }
        }
        .accessibilityHidden(true)
    }
}

/// Row of small heart icons, filled up to `value` out of `max`; always draws at
/// least one slot even when `max` is zero.
struct HeartsRow: View {
    let value: Int
    let max: Int

    var body: some View {
        HStack(spacing: 1) {
            ForEach(0..<Swift.max(1, max), id: \.self) { index in
                Image(systemName: index < value ? "heart.fill" : "heart")
                    .font(.system(size: 9))
            }
        }
    }
}

/// Root complication content; switches on the widget family, with every family
/// other than rectangular, inline and corner falling through to `CircularView`.
struct ComplicationView: View {
    @Environment(\.widgetFamily) private var family
    let entry: WidgetEntry

    var body: some View {
        switch family {
        case .accessoryRectangular: RectangularView(entry: entry)
        case .accessoryInline: InlineView(entry: entry)
        case .accessoryCorner: CornerView(entry: entry)
        default: CircularView(entry: entry)
        }
    }
}

/// Circular complication: the baked sprite centred on the system widget
/// background.
struct CircularView: View {
    let entry: WidgetEntry

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            SpriteCanvas(rows: entry.spriteRows).padding(5)
        }
        .accessibilityLabel("Stepkin, \(entry.statusText)")
    }
}

/// Rectangular complication: the sprite beside the species name, a hunger
/// `HeartsRow`, and the status text, prefixed with "needs" when the pet needs
/// attention.
struct RectangularView: View {
    let entry: WidgetEntry

    var body: some View {
        HStack(spacing: 6) {
            SpriteCanvas(rows: entry.spriteRows).frame(width: 30, height: 30)
            VStack(alignment: .leading, spacing: 1) {
                Text(entry.speciesName)
                    .font(.headline)
                    .widgetAccentable()
                HeartsRow(value: entry.hungerValue, max: entry.hungerMax)
                Text(entry.needsAttention ? "needs \(entry.statusText)" : entry.statusText)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .accessibilityLabel("\(entry.speciesName), \(entry.statusText)")
    }
}

/// Inline complication: a single-line label of the status text with a warning
/// glyph when the pet needs attention, a pawprint otherwise.
struct InlineView: View {
    let entry: WidgetEntry

    var body: some View {
        Label(
            "Stepkin \u{00b7} \(entry.statusText)",
            systemImage: entry.needsAttention ? "exclamationmark.circle" : "pawprint"
        )
    }
}

/// Corner complication: the baked sprite with a widget label gauge of hunger
/// against the maximum heart count.
struct CornerView: View {
    let entry: WidgetEntry

    var body: some View {
        SpriteCanvas(rows: entry.spriteRows)
            .widgetLabel {
                Gauge(value: Double(entry.hungerValue), in: 0...Double(Swift.max(1, entry.hungerMax))) {
                    Text(entry.statusText)
                }
            }
            .accessibilityLabel("Stepkin, \(entry.statusText)")
    }
}
