import SwiftUI

/// Current temperature, humidity and condition, shown above the LCD. (The
/// weather *icon* lives in the debug row by the pet's name.)
struct WeatherOverlay: View {

    let snapshot: WeatherSnapshot
    @Environment(\.lcdTheme) private var theme

    var body: some View {
        // Largest layout that fits wins: Ultra shows temp · humidity · condition;
        // narrow 40/42mm screens drop humidity, then condition — longest-first —
        // so the temperature never truncates. Humidity goes before condition,
        // since the condition is the only weather cue in a release build.
        ViewThatFits(in: .horizontal) {
            row(showHumidity: true, showCondition: true)
            row(showHumidity: false, showCondition: true)
            row(showHumidity: false, showCondition: false)
        }
        .lineLimit(1)
        .minimumScaleFactor(0.7)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            "\(snapshot.condition.displayName), "
                + WeatherTemperatureFormatter.string(for: snapshot.temperature)
                + ", humidity \(humidityText)"
        )
    }

    private func row(showHumidity: Bool, showCondition: Bool) -> some View {
        HStack(spacing: 3) {
            field(WeatherTemperatureFormatter.string(for: snapshot.temperature), opacity: 1)
            if showHumidity {
                separator
                field(humidityText, opacity: 0.65)
            }
            if showCondition {
                separator
                field(snapshot.condition.displayName, opacity: 1)
            }
        }
    }

    private func field(_ text: String, opacity: Double) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .bold, design: .monospaced))
            .foregroundStyle(theme.chromeTint.opacity(opacity))
    }

    private var separator: some View {
        Text("|")
            .font(.system(size: 11, weight: .bold, design: .monospaced))
            .foregroundStyle(theme.chromeTint.opacity(0.35))
    }

    private var humidityText: String {
        "\(Int((snapshot.humidity * 100).rounded()))%"
    }
}

/// Draws a single 16x16 SpriteFrame at a small pixel size.
struct WeatherIconView: View {

    let frame: SpriteFrame
    let pixelSize: CGFloat

    var body: some View {
        Canvas { context, _ in
            for y in 0..<SpriteFrame.size {
                for x in 0..<SpriteFrame.size where frame.pixel(x: x, y: y) {
                    let rect = CGRect(
                        x: CGFloat(x) * pixelSize,
                        y: CGFloat(y) * pixelSize,
                        width: pixelSize + 0.5,
                        height: pixelSize + 0.5
                    )
                    context.fill(Path(rect), with: .color(.white))
                }
            }
        }
        .frame(
            width: CGFloat(SpriteFrame.size) * pixelSize,
            height: CGFloat(SpriteFrame.size) * pixelSize
        )
        .accessibilityHidden(true)
    }
}

#if DEBUG
#Preview {
    WeatherOverlay(snapshot: .sample)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black)
}
#endif
