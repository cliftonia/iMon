import SwiftUI

struct LCDDisplay: View {

    let leftSprite: SpriteFrame
    let rightSprite: SpriteFrame?
    let poopCount: Int
    let stinkPhase: Int
    let lightsOn: Bool
    let leftSpriteOffsetX: Int
    let leftSpriteOffsetY: Int
    let rightSpriteOffsetY: Int
    let weatherCondition: WeatherIconCondition?
    let moonPhase: MoonPhase

    init(
        leftSprite: SpriteFrame,
        rightSprite: SpriteFrame? = nil,
        poopCount: Int = 0,
        stinkPhase: Int = 0,
        lightsOn: Bool = true,
        leftSpriteOffsetX: Int = 8,
        leftSpriteOffsetY: Int = 4,
        rightSpriteOffsetY: Int = 4,
        weatherCondition: WeatherIconCondition? = nil,
        moonPhase: MoonPhase = .full
    ) {
        self.leftSprite = leftSprite
        self.rightSprite = rightSprite
        self.poopCount = poopCount
        self.stinkPhase = stinkPhase
        self.lightsOn = lightsOn
        self.leftSpriteOffsetX = leftSpriteOffsetX
        self.leftSpriteOffsetY = leftSpriteOffsetY
        self.rightSpriteOffsetY = rightSpriteOffsetY
        self.weatherCondition = weatherCondition
        self.moonPhase = moonPhase
    }

    /// Every known condition now has an animated overlay.
    private var hasWeatherEffect: Bool {
        weatherCondition != nil
    }

    private static let weatherFrameInterval: TimeInterval = 0.18

    // MARK: - Colors

    private var backgroundColor: Color {
        lightsOn ? Color("LCDBackground") : Color(white: 0.07)
    }

    /// The "lit pixel" colour. Not private — the weather extension draws with it.
    var basePixelColor: Color {
        lightsOn ? Color("LCDPixelOn") : .white
    }

    var body: some View {
        if hasWeatherEffect {
            TimelineView(.periodic(from: .now, by: Self.weatherFrameInterval)) { timeline in
                // Wrap the tick count well within 32-bit Int range (watchOS is
                // arm64_32) — the effects all cycle on `% n` so a slow wrap is fine.
                let ticks = timeline.date.timeIntervalSinceReferenceDate
                    / Self.weatherFrameInterval
                let phase = Int(ticks.truncatingRemainder(dividingBy: 1_000_000))
                styledCanvas(weatherPhase: phase)
            }
        } else {
            styledCanvas(weatherPhase: 0)
        }
    }

    private func styledCanvas(weatherPhase: Int) -> some View {
        Canvas { context, size in
            let pixelWidth = size.width / 32
            let pixelHeight = size.height / 20

            drawGrid(
                in: context,
                size: size,
                pixelWidth: pixelWidth,
                pixelHeight: pixelHeight
            )

            drawGround(
                in: context,
                size: size,
                pixelWidth: pixelWidth,
                pixelHeight: pixelHeight
            )

            drawSprites(
                in: context,
                pixelWidth: pixelWidth,
                pixelHeight: pixelHeight
            )

            drawPoop(
                in: context,
                pixelWidth: pixelWidth,
                pixelHeight: pixelHeight
            )

            drawWeather(
                phase: weatherPhase,
                in: context,
                pixelWidth: pixelWidth,
                pixelHeight: pixelHeight
            )

            drawLightning(
                phase: weatherPhase,
                in: context,
                size: size,
                pixelWidth: pixelWidth,
                pixelHeight: pixelHeight
            )
        }
        .background(backgroundColor)
        .aspectRatio(32.0 / 20.0, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .accessibilityHidden(true)
    }

    // MARK: - Sprites

    /// Draws the creature and any right-hand effect sprite (food, skull).
    private func drawSprites(
        in context: GraphicsContext,
        pixelWidth: CGFloat,
        pixelHeight: CGFloat
    ) {
        drawSprite(
            leftSprite,
            in: context,
            offsetX: leftSpriteOffsetX,
            offsetY: leftSpriteOffsetY,
            pixelWidth: pixelWidth,
            pixelHeight: pixelHeight
        )
        if let rightSprite {
            drawSprite(
                rightSprite,
                in: context,
                offsetX: 20,
                offsetY: rightSpriteOffsetY,
                pixelWidth: pixelWidth,
                pixelHeight: pixelHeight
            )
        }
    }

    private func drawSprite(
        _ sprite: SpriteFrame,
        in context: GraphicsContext,
        offsetX: Int,
        offsetY: Int = 0,
        pixelWidth: CGFloat,
        pixelHeight: CGFloat
    ) {
        let pixelColor = basePixelColor

        for y in 0..<SpriteFrame.size {
            for x in 0..<SpriteFrame.size {
                guard sprite.pixel(x: x, y: y) else { continue }
                let rect = CGRect(
                    x: Double(x + offsetX) * pixelWidth,
                    y: Double(y + offsetY) * pixelHeight,
                    width: pixelWidth + 0.5,
                    height: pixelHeight + 0.5
                )
                context.fill(
                    Path(rect),
                    with: .color(pixelColor)
                )
            }
        }
    }

    // MARK: - Poop

    private func drawPoop(
        in context: GraphicsContext,
        pixelWidth: CGFloat,
        pixelHeight: CGFloat
    ) {
        guard poopCount > 0 else { return }
        let color = basePixelColor

        // Poop pile positions on the 32x20 LCD (ground at row 19)
        let bases: [(x: Int, y: Int)] = [
            (25, 16), (29, 16),
            (25, 13), (29, 13)
        ]

        // Coiled poop pile: tip + mound + base
        let pilePixels: [(dx: Int, dy: Int)] = [
            (1, 0),
            (0, 1), (1, 1),
            (0, 2), (1, 2), (2, 2)
        ]

        func fillPixel(x: Int, y: Int, _ pixelColor: Color) {
            let rect = CGRect(
                x: Double(x) * pixelWidth,
                y: Double(y) * pixelHeight,
                width: pixelWidth + 0.5,
                height: pixelHeight + 0.5
            )
            context.fill(Path(rect), with: .color(pixelColor))
        }

        for i in 0..<min(poopCount, 4) {
            let base = bases[i]
            for p in pilePixels {
                fillPixel(
                    x: base.x + p.dx,
                    y: base.y + p.dy,
                    color
                )
            }
        }

        // Stink wavy lines above poop area
        let stinkColor = basePixelColor.opacity(0.7)
        let stinkPixels: [(x: Int, y: Int)]
        if stinkPhase % 2 == 0 {
            stinkPixels = [(26, 12), (28, 11), (30, 12)]
        } else {
            stinkPixels = [(25, 11), (27, 12), (31, 11)]
        }
        for p in stinkPixels {
            fillPixel(x: p.x, y: p.y, stinkColor)
        }
    }
}
