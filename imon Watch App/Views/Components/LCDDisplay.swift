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

    init(
        leftSprite: SpriteFrame,
        rightSprite: SpriteFrame? = nil,
        poopCount: Int = 0,
        stinkPhase: Int = 0,
        lightsOn: Bool = true,
        leftSpriteOffsetX: Int = 8,
        leftSpriteOffsetY: Int = 4,
        rightSpriteOffsetY: Int = 4,
        weatherCondition: WeatherIconCondition? = nil
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
    }

    /// Conditions that get an animated overlay on the LCD.
    private var hasWeatherEffect: Bool {
        switch weatherCondition {
        case .rain, .snow, .storm, .wind, .fog: true
        case .clear, .cloudy, .none: false
        }
    }

    private static let weatherFrameInterval: TimeInterval = 0.18

    // MARK: - Colors

    private var backgroundColor: Color {
        lightsOn ? Color("LCDBackground") : Color(white: 0.07)
    }

    private var basePixelColor: Color {
        lightsOn ? Color("LCDPixelOn") : .white
    }

    var body: some View {
        if hasWeatherEffect {
            TimelineView(.periodic(from: .now, by: Self.weatherFrameInterval)) { timeline in
                let phase = Int(
                    timeline.date.timeIntervalSinceReferenceDate
                        / Self.weatherFrameInterval
                )
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
        }
        .background(backgroundColor)
        .aspectRatio(32.0 / 20.0, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .accessibilityHidden(true)
    }

    // MARK: - Weather Effects

    private func drawWeather(
        phase: Int,
        in context: GraphicsContext,
        pixelWidth: CGFloat,
        pixelHeight: CGFloat
    ) {
        let cells: [(x: Int, y: Int)]
        let color: Color
        switch weatherCondition {
        case .rain:
            cells = Self.rainCells(phase: phase)
            color = basePixelColor
        case .storm:
            cells = Self.rainCells(phase: phase) + Self.lightningCells(phase: phase)
            color = basePixelColor
        case .snow:
            cells = Self.snowCells(phase: phase)
            color = basePixelColor
        case .wind:
            cells = Self.windCells(phase: phase)
            color = basePixelColor.opacity(0.8)
        case .fog:
            cells = Self.fogCells(phase: phase)
            color = basePixelColor.opacity(0.4)
        case .clear, .cloudy, .none:
            cells = []
            color = basePixelColor
        }

        for cell in cells where cell.x >= 0 && cell.x < 32 && cell.y >= 0 && cell.y < 20 {
            let rect = CGRect(
                x: Double(cell.x) * pixelWidth,
                y: Double(cell.y) * pixelHeight,
                width: pixelWidth + 0.5,
                height: pixelHeight + 0.5
            )
            context.fill(Path(rect), with: .color(color))
        }
    }

    /// Diagonal falling streaks.
    private static func rainCells(phase: Int) -> [(x: Int, y: Int)] {
        let columns = [1, 6, 10, 15, 19, 24, 28, 31]
        var cells: [(x: Int, y: Int)] = []
        for (index, col) in columns.enumerated() {
            let y = (phase * 2 + index * 5) % 19
            let x = (col + y / 4) % 32
            cells.append((x: x, y: y))
            cells.append((x: x, y: y - 1))
        }
        return cells
    }

    /// Slow drifting flakes that sway side to side.
    private static func snowCells(phase: Int) -> [(x: Int, y: Int)] {
        let columns = [2, 7, 12, 16, 21, 26, 30]
        return columns.enumerated().map { index, col in
            let y = (phase / 2 + index * 3) % 19
            let sway = ((phase / 4 + index) % 4) < 2 ? 0 : 1
            return (x: (col + sway) % 32, y: y)
        }
    }

    /// Horizontal gusts streaking to the right.
    private static func windCells(phase: Int) -> [(x: Int, y: Int)] {
        let rows = [4, 9, 14]
        var cells: [(x: Int, y: Int)] = []
        for (index, row) in rows.enumerated() {
            let start = (phase * 2 + index * 11) % 42 - 6
            for dx in [0, 1, 2, 3, 6, 7] {
                cells.append((x: start + dx, y: row))
            }
        }
        return cells
    }

    /// Drifting dashed bands.
    private static func fogCells(phase: Int) -> [(x: Int, y: Int)] {
        let rows = [5, 10, 15]
        var cells: [(x: Int, y: Int)] = []
        for (index, row) in rows.enumerated() {
            let off = phase / 2 + index * 3
            for x in 0..<32 where ((x + off) / 3) % 2 == 0 {
                cells.append((x: x, y: row))
            }
        }
        return cells
    }

    /// A brief lightning bolt every ~16 frames.
    private static func lightningCells(phase: Int) -> [(x: Int, y: Int)] {
        guard phase % 16 == 0 else { return [] }
        return [
            (16, 1), (16, 2), (15, 3), (16, 4),
            (15, 5), (14, 6), (15, 7), (14, 8)
        ].map { (x: $0.0, y: $0.1) }
    }

    // MARK: - Grid & Ground

    private func drawGrid(
        in context: GraphicsContext,
        size: CGSize,
        pixelWidth: CGFloat,
        pixelHeight: CGFloat
    ) {
        let gridColor = basePixelColor.opacity(0.06)

        for col in stride(from: 0, through: 32, by: 4) {
            let x = Double(col) * pixelWidth
            let line = Path(
                CGRect(
                    x: x, y: 0,
                    width: 0.5, height: size.height
                )
            )
            context.fill(line, with: .color(gridColor))
        }
        for row in stride(from: 0, through: 20, by: 4) {
            let y = Double(row) * pixelHeight
            let line = Path(
                CGRect(
                    x: 0, y: y,
                    width: size.width, height: 0.5
                )
            )
            context.fill(line, with: .color(gridColor))
        }
    }

    private func drawGround(
        in context: GraphicsContext,
        size: CGSize,
        pixelWidth: CGFloat,
        pixelHeight: CGFloat
    ) {
        let groundColor = basePixelColor.opacity(0.12)

        let groundY = 19.0 * pixelHeight
        let groundLine = Path(
            CGRect(
                x: 0, y: groundY,
                width: size.width, height: pixelHeight
            )
        )
        context.fill(groundLine, with: .color(groundColor))

        let tufts: [Int] = [1, 5, 10, 15, 21, 26, 30]
        let tuftColor = basePixelColor.opacity(0.10)
        for col in tufts {
            let rect = CGRect(
                x: Double(col) * pixelWidth,
                y: 18.0 * pixelHeight,
                width: pixelWidth,
                height: pixelHeight
            )
            context.fill(Path(rect), with: .color(tuftColor))
        }
    }

    // MARK: - Sprites

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
