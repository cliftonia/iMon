import SwiftUI

struct LCDDisplay: View {

    let configuration: LCDDisplayConfiguration

    /// The active palette - `nightRed` in battery-saver mode, else `classic`.
    @Environment(\.lcdTheme) private var theme

    // Field accessors so the drawing code (and the +Weather/+Inside extensions)
    // read directly off the configuration.
    var leftSprite: SpriteFrame { configuration.leftSprite }
    var rightSprite: SpriteFrame? { configuration.rightSprite }
    var poopCount: Int { configuration.poopCount }
    var stinkPhase: Int { configuration.stinkPhase }
    var lightsOn: Bool { configuration.lightsOn }
    var leftSpriteOffsetX: Int { configuration.leftSpriteOffsetX }
    var leftSpriteOffsetY: Int { configuration.leftSpriteOffsetY }
    var rightSpriteOffsetY: Int { configuration.rightSpriteOffsetY }
    var weatherCondition: WeatherIconCondition? { configuration.weatherCondition }
    var moonPhase: MoonPhase { configuration.moonPhase }
    var dayPhase: DayPhase { configuration.dayPhase }
    var stormFlash: Bool { configuration.stormFlash }
    var showCallSign: Bool { configuration.showCallSign }

    /// Whether the LCD has an animated overlay (weather, storm flash, or the
    /// blinking Call sign) and so needs the periodic timeline to drive it.
    private var isAnimated: Bool {
        weatherCondition != nil || stormFlash || showCallSign
    }

    /// Lit at night - the weather plays in a window inside a room.
    private var isIndoor: Bool {
        dayPhase == .inside
    }

    private static let weatherFrameInterval: TimeInterval = 0.18

    // MARK: - Colors

    private var backgroundColor: Color {
        theme.backgroundColor(lightsOn: lightsOn)
    }

    /// The "lit pixel" colour. Not private - the weather extension draws with it.
    var basePixelColor: Color {
        theme.pixelColor(lightsOn: lightsOn)
    }

    /// True when the screen background is dark - the lights-off night scene or the
    /// red battery-saver palette. Not private - the scene extension reads it to
    /// lift the faint grid and ground, since a bright line at low opacity is all
    /// but invisible on black. On the lit green day screen the low opacity reads.
    var isDarkScreen: Bool {
        theme == .nightRed || !lightsOn
    }

    /// The room's ambient shade, away from the lamp's bright pool. Shared by the
    /// indoor glow and the eye-hole backing so they stay in step.
    static let roomAmbientColor = Color(red: 84 / 255, green: 108 / 255, blue: 68 / 255)

    /// Interior-hole masks are pure functions of the sprite, so cache them —
    /// the flood fill would otherwise rerun for every sprite on every canvas
    /// tick (several per second whenever weather or the call sign animates).
    private static var holeCache: [SpriteFrame: SpriteFrame] = [:]

    private static func interiorHoles(of sprite: SpriteFrame) -> SpriteFrame {
        if let cached = holeCache[sprite] { return cached }
        let holes = sprite.interiorHoles()
        // The frame catalog is finite, but composed one-off frames (overlays,
        // shifts) could grow the cache slowly — reset rather than grow forever.
        if holeCache.count > 512 { holeCache.removeAll(keepingCapacity: true) }
        holeCache[sprite] = holes
        return holes
    }

    var body: some View {
        if isAnimated {
            TimelineView(.periodic(from: .now, by: Self.weatherFrameInterval)) { timeline in
                // Wrap the tick count well within 32-bit Int range (watchOS is
                // arm64_32) - the effects all cycle on `% n` so a slow wrap is fine.
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
            drawScene(weatherPhase: weatherPhase, in: context, size: size)
        }
        .background(backgroundColor)
        .aspectRatio(32.0 / 20.0, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .accessibilityHidden(true)
    }

    private func drawScene(
        weatherPhase: Int,
        in context: GraphicsContext,
        size: CGSize
    ) {
        let pixelWidth = size.width / 32
        let pixelHeight = size.height / 20

        // Dim room with a bright pool under the lamp (indoors only).
        if isIndoor {
            drawRoomGlow(
                in: context, size: size,
                pixelWidth: pixelWidth, pixelHeight: pixelHeight
            )
        }

        drawGrid(in: context, size: size, pixelWidth: pixelWidth, pixelHeight: pixelHeight)
        drawGround(in: context, size: size, pixelWidth: pixelWidth, pixelHeight: pixelHeight)

        // Indoors the room (window, weather, furniture, lamp) sits behind the
        // pet; outdoors the weather plays over everything.
        if isIndoor {
            drawWeather(
                phase: weatherPhase, in: context,
                pixelWidth: pixelWidth, pixelHeight: pixelHeight
            )
        }

        drawSprites(in: context, pixelWidth: pixelWidth, pixelHeight: pixelHeight)
        drawPoop(in: context, pixelWidth: pixelWidth, pixelHeight: pixelHeight)

        if !isIndoor {
            drawWeather(
                phase: weatherPhase, in: context,
                pixelWidth: pixelWidth, pixelHeight: pixelHeight
            )
            drawLightning(
                phase: weatherPhase, in: context, size: size,
                pixelWidth: pixelWidth, pixelHeight: pixelHeight
            )
            // Outdoors the sky/weather plays in front of the pet, so re-stamp the
            // creature's eyes on top - otherwise a walking pet's eyes sweep across
            // the animated layer and flicker as sun, stars or rain pass behind.
            // Skipped while a lightning flash washes the screen: the flash covers
            // the body too, and dark eye holes would punch through the white-out.
            if !isFlashFrame(phase: weatherPhase) {
                fillInteriorHoles(
                    leftSprite, in: context,
                    offsetX: leftSpriteOffsetX, offsetY: leftSpriteOffsetY,
                    pixelWidth: pixelWidth, pixelHeight: pixelHeight
                )
            }
        }

        // Call sign last of all, so the attention alert reads over any scene.
        drawCallSign(
            phase: weatherPhase, in: context,
            pixelWidth: pixelWidth, pixelHeight: pixelHeight
        )
    }

    // MARK: - Call Sign

    /// The toy's attention alert: a blinking "!" in the top-left while the pet
    /// is languishing (hunger and strength both empty), summoning care.
    private func drawCallSign(
        phase: Int,
        in context: GraphicsContext,
        pixelWidth: CGFloat,
        pixelHeight: CGFloat
    ) {
        guard showCallSign, (phase / 3) % 2 == 0 else { return }

        // A 2px-wide exclamation mark tucked into the top-left corner.
        context.fillLCDCells(
            [
                (1, 0), (2, 0), (1, 1), (2, 1), (1, 2), (2, 2),
                (1, 4), (2, 4)
            ],
            pixelWidth: pixelWidth, pixelHeight: pixelHeight,
            color: basePixelColor
        )
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

        // Enclosed holes first, blocking whatever is drawn behind the body.
        fillInteriorHoles(
            sprite, in: context,
            offsetX: offsetX, offsetY: offsetY,
            pixelWidth: pixelWidth, pixelHeight: pixelHeight
        )

        // The lit body on top.
        for y in 0..<SpriteFrame.size {
            for x in 0..<SpriteFrame.size where sprite.pixel(x: x, y: y) {
                context.fillCell(
                    x: x + offsetX, y: y + offsetY,
                    pixelWidth: pixelWidth, pixelHeight: pixelHeight,
                    color: pixelColor
                )
            }
        }
    }

    /// Fills a sprite's enclosed holes (eyes, mouths) with opaque,
    /// scene-matched shading so the gap keeps the bare-eye look while nothing
    /// shows through it. Run under the body to block the backdrop behind, and
    /// again on top of front-drawn weather so a walking pet's eyes never flicker.
    /// Indoors the backing is the same radial lamp gradient as the room glow,
    /// so eyes match the wall behind them wherever the pet stands.
    func fillInteriorHoles(
        _ sprite: SpriteFrame,
        in context: GraphicsContext,
        offsetX: Int,
        offsetY: Int = 0,
        pixelWidth: CGFloat,
        pixelHeight: CGFloat
    ) {
        let holes = Self.interiorHoles(of: sprite)
        var path = Path()
        for y in 0..<SpriteFrame.size {
            for x in 0..<SpriteFrame.size where holes.pixel(x: x, y: y) {
                path.addRect(CGRect(
                    x: Double(x + offsetX) * pixelWidth,
                    y: Double(y + offsetY) * pixelHeight,
                    width: pixelWidth + 0.5,
                    height: pixelHeight + 0.5
                ))
            }
        }
        guard !path.isEmpty else { return }
        let shading: GraphicsContext.Shading = isIndoor
            ? roomGlowShading(pixelWidth: pixelWidth, pixelHeight: pixelHeight)
            : .color(backgroundColor)
        context.fill(path, with: shading)
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

        for i in 0..<min(poopCount, 4) {
            let base = bases[i]
            for p in pilePixels {
                context.fillCell(
                    x: base.x + p.dx, y: base.y + p.dy,
                    pixelWidth: pixelWidth, pixelHeight: pixelHeight,
                    color: color
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
        context.fillLCDCells(
            stinkPixels,
            pixelWidth: pixelWidth, pixelHeight: pixelHeight,
            color: stinkColor
        )
    }
}
