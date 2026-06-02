import SwiftUI

/// Weather condition icon + current temperature, shown above the LCD.
struct WeatherOverlay: View {

    let snapshot: WeatherSnapshot

    var body: some View {
        HStack(spacing: 4) {
            WeatherIconView(
                frame: WeatherIconMapper.frame(
                    for: snapshot.condition,
                    isDaylight: snapshot.isDaylight
                ),
                pixelSize: 1.0
            )
            separator
            Text(WeatherTemperatureFormatter.string(for: snapshot.temperature))
                .font(.system(size: 13, weight: .bold, design: .monospaced))
                .foregroundStyle(.white)
            separator
            Text(humidityText)
                .font(.system(size: 13, weight: .bold, design: .monospaced))
                .foregroundStyle(.white.opacity(0.65))
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            "Weather: \(String(describing: snapshot.condition)), "
                + WeatherTemperatureFormatter.string(for: snapshot.temperature)
                + ", humidity \(humidityText)"
        )
    }

    private var separator: some View {
        Text("|")
            .font(.system(size: 13, weight: .bold, design: .monospaced))
            .foregroundStyle(.white.opacity(0.35))
    }

    private var humidityText: String {
        "\(Int((snapshot.humidity * 100).rounded()))%"
    }
}

/// Draws a single 16x16 SpriteFrame at a small pixel size.
private struct WeatherIconView: View {

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
