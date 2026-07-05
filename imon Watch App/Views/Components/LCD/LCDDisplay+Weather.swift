import SwiftUI

// MARK: - Weather Effects

extension LCDDisplay {

    /// A brighter shade of the LCD green for the daytime lightning flash.
    static let lightningFlashColor = Color(
        red: 200 / 255, green: 230 / 255, blue: 160 / 255
    )

    func drawWeather(
        phase: Int,
        in context: GraphicsContext,
        pixelWidth: CGFloat,
        pixelHeight: CGFloat
    ) {
        // Inside (lit at night): the weather is confined to the window and
        // reads as the bright night sky on the dark pane.
        let indoor = dayPhase == .inside
        func fill(_ cells: [(x: Int, y: Int)], _ opacity: Double) {
            let paint = (indoor ? Color.white : basePixelColor).opacity(opacity)
            for cell in cells
            where cell.x >= 0 && cell.x < 32 && cell.y >= 0 && cell.y < 20
                && (!indoor
                    || (Self.windowCols.contains(cell.x) && Self.windowRows.contains(cell.y))) {
                let rect = CGRect(
                    x: Double(cell.x) * pixelWidth,
                    y: Double(cell.y) * pixelHeight,
                    width: pixelWidth + 0.5,
                    height: pixelHeight + 0.5
                )
                context.fill(Path(rect), with: .color(paint))
            }
        }

        if indoor {
            drawWindowPane(in: context, pixelWidth: pixelWidth, pixelHeight: pixelHeight)
        }
        drawConditionLayers(phase: phase, fill: fill)
        if indoor {
            drawRoomChrome(
                phase: phase, in: context,
                pixelWidth: pixelWidth, pixelHeight: pixelHeight
            )
        }
    }

    /// Draws the active weather condition's layers via the supplied fill,
    /// which paints the given cells at the given opacity.
    private func drawConditionLayers(
        phase: Int,
        fill: ([(x: Int, y: Int)], Double) -> Void
    ) {
        switch weatherCondition {
        case .rain, .storm:
            // Two-layer depth: dim distant drops, bright near streaks. Storm
            // adds the lightning flash (drawn over the scene afterwards).
            fill(Self.rainBackCells(phase: phase), 0.4)
            fill(Self.rainFrontCells(phase: phase), 1)
        case .snow:
            fill(Self.snowBackCells(phase: phase), 0.4)
            fill(Self.snowFrontCells(phase: phase), 1)
        case .wind:
            fill(Self.windBackCells(phase: phase), 0.35)
            fill(Self.windFrontCells(phase: phase), 0.85)
        case .fog:
            fill(Self.fogBackCells(phase: phase), 0.25)
            fill(Self.fogFrontCells(phase: phase), 0.45)
        case .clear:
            if dayPhase == .day {
                fill(Self.sunCells(phase: phase), 0.4)
            } else {
                // Full moon disc dim, with the lit fraction bright on top.
                fill(Self.moonDiscCells(), 0.3)
                fill(Self.moonLitCells(moonPhase), 1)
                fill(Self.starCells(phase: phase), 1)
                fill(Self.shootingStarCells(phase: phase), 1)
            }
        case .cloudy:
            fill(Self.cloudCells(phase: phase), 0.55)
        case .none:
            break
        }
    }

    /// Whether this tick is inside a lightning white-out (storm weather or the
    /// battle storm flash), i.e. the whole screen is washed by the flash fill.
    /// The eye re-stamp is skipped on these frames so dark holes don't punch
    /// through the flash.
    func isFlashFrame(phase: Int) -> Bool {
        guard (weatherCondition == .storm && dayPhase != .inside) || stormFlash else {
            return false
        }
        return stormFlash
            ? Self.isVSFlash(phase)
            : Self.isLightningFlash(phase)
    }

    /// Full-screen lightning: a bright flash plus jagged diagonal bolts.
    /// Drawn for weather storms and — with a bold "VS" — the battle intro.
    func drawLightning(
        phase: Int,
        in context: GraphicsContext,
        size: CGSize,
        pixelWidth: CGFloat,
        pixelHeight: CGFloat
    ) {
        // Indoors the storm shows as rain through the window, not a room-wide flash.
        guard (weatherCondition == .storm && dayPhase != .inside) || stormFlash else {
            return
        }

        func fillCells(_ cells: [(x: Int, y: Int)], _ color: Color) {
            context.fillLCDCells(
                cells,
                pixelWidth: pixelWidth, pixelHeight: pixelHeight,
                color: color
            )
        }

        // The "VS" sits under the flash, so each lightning pop washes over it.
        if stormFlash {
            fillCells(Self.vsShadowCells(), basePixelColor.opacity(0.3))
            fillCells(Self.vsTextCells(), basePixelColor)
        }

        guard isFlashFrame(phase: phase) else { return }

        // Flash in the active palette: bright green when lit, dim grey at night.
        let flashColor = lightsOn ? Self.lightningFlashColor : Color(white: 0.35)
        context.fill(
            Path(CGRect(origin: .zero, size: size)),
            with: .color(flashColor.opacity(0.9))
        )
        // Bolts in the LCD pixel colour, dark against the lit screen.
        fillCells(Self.lightningBoltCells(), basePixelColor)
    }

    // MARK: - Precipitation

    /// Near rain — bright, fast, 2px diagonal streaks.
    private static func rainFrontCells(phase: Int) -> [(x: Int, y: Int)] {
        let columns = [1, 7, 13, 19, 25, 30]
        var cells: [(x: Int, y: Int)] = []
        for (index, col) in columns.enumerated() {
            let y = (phase * 3 + index * 4) % 21 - 1
            let x = (col + y / 5) % 32
            cells.append((x: x, y: y))
            cells.append((x: x, y: y - 1))
        }
        return cells
    }

    /// Far rain — dim, slower, single-pixel drops.
    private static func rainBackCells(phase: Int) -> [(x: Int, y: Int)] {
        let columns = [4, 10, 16, 22, 28]
        return columns.enumerated().map { index, col in
            (x: col, y: (phase * 2 + index * 6) % 20)
        }
    }

    /// Near snow layer — bright, faster fall, gentle sway.
    private static func snowFrontCells(phase: Int) -> [(x: Int, y: Int)] {
        let flakes: [(col: Int, offset: Int)] = [
            (3, 0), (9, 7), (15, 3), (21, 12), (27, 5), (31, 15)
        ]
        return flakes.map { flake in
            let y = (phase + flake.offset) % 20
            let sway = (phase / 2 + flake.col) % 4
            let dx = sway == 0 ? -1 : (sway == 2 ? 1 : 0)
            return (x: (flake.col + dx + 32) % 32, y: y)
        }
    }

    /// Far snow layer — dim, slow fall, no sway (distant).
    private static func snowBackCells(phase: Int) -> [(x: Int, y: Int)] {
        let flakes: [(col: Int, offset: Int)] = [
            (1, 4), (7, 13), (12, 1), (18, 9), (24, 16), (29, 6)
        ]
        return flakes.map { flake in
            (x: flake.col, y: (phase / 2 + flake.offset) % 20)
        }
    }

    // MARK: - Wind

    /// Near wind — bright curved gust streaks, with debris carried along.
    private static func windFrontCells(phase: Int) -> [(x: Int, y: Int)] {
        var cells: [(x: Int, y: Int)] = []
        let curve = [0, 0, 1, 1, 1, 0, 0, 0, 0, 0]
        for (row, length, speed) in [(4, 8, 3), (9, 10, 2), (14, 7, 3)] {
            let head = (phase * speed) % 46 - 10
            for i in 0..<length {
                cells.append((x: head - i, y: row + curve[i % curve.count]))
            }
        }
        // Debris whipped along on the wind.
        for (offset, row) in [(0, 7), (5, 12), (3, 17)] {
            cells.append((x: (phase * 2 + offset * 9) % 40 - 4, y: row))
        }
        return cells
    }

    /// Far wind — dim, slower, straight thin streaks between the near gusts.
    private static func windBackCells(phase: Int) -> [(x: Int, y: Int)] {
        var cells: [(x: Int, y: Int)] = []
        for (row, length, speed) in [(2, 6, 1), (11, 7, 2), (16, 5, 1)] {
            let head = (phase * speed + row * 3) % 44 - 8
            for i in 0..<length {
                cells.append((x: head - i, y: row))
            }
        }
        return cells
    }

    // MARK: - Fog

    /// A soft horizontal wisp with feathered (dithered) ends.
    private static func fogWisp(x0: Int, row: Int, length: Int) -> [(x: Int, y: Int)] {
        var cells: [(x: Int, y: Int)] = []
        for i in 0..<length {
            let edge = min(i, length - 1 - i)
            if edge >= 2 || i % 2 == 0 {
                cells.append((x: x0 + i, y: row))
            }
        }
        return cells
    }

    /// Far fog layer — long, dim wisps drifting slowly.
    private static func fogBackCells(phase: Int) -> [(x: Int, y: Int)] {
        var cells: [(x: Int, y: Int)] = []
        for (row, off, length) in [(3, 0, 16), (9, 7, 20), (15, 3, 14)] {
            let x0 = (phase / 3 + off) % 50 - 18
            cells += fogWisp(x0: x0, row: row, length: length)
        }
        return cells
    }

    /// Near fog layer — shorter, denser wisps drifting a touch faster.
    private static func fogFrontCells(phase: Int) -> [(x: Int, y: Int)] {
        var cells: [(x: Int, y: Int)] = []
        for (row, off, length) in [(6, 0, 12), (12, 9, 16), (17, 4, 10)] {
            let x0 = (phase / 2 + off) % 46 - 14
            cells += fogWisp(x0: x0, row: row, length: length)
        }
        return cells
    }

    // MARK: - Clouds & Lightning

    /// Big soft clouds drifting across the sky at parallax speeds.
    private static func cloudCells(phase: Int) -> [(x: Int, y: Int)] {
        let puff = [
            (2, 0), (3, 0), (6, 0), (7, 0),
            (1, 1), (2, 1), (3, 1), (4, 1), (5, 1), (6, 1), (7, 1), (8, 1),
            (0, 2), (1, 2), (2, 2), (3, 2), (4, 2), (5, 2), (6, 2), (7, 2), (8, 2), (9, 2),
            (1, 3), (2, 3), (3, 3), (4, 3), (5, 3), (6, 3), (7, 3), (8, 3)
        ]
        var cells: [(x: Int, y: Int)] = []
        for (row, speed, start) in [(1, 2, 0), (7, 3, 20)] {
            let x0 = (phase / speed + start) % 46 - 11
            for (dx, dy) in puff {
                cells.append((x: x0 + dx, y: row + dy))
            }
        }
        return cells
    }

    /// A quick double-blink every ~4 seconds, like a real lightning flicker.
    private static func isLightningFlash(_ phase: Int) -> Bool {
        let cycle = phase % 22
        return cycle == 0 || cycle == 2
    }

    /// Several jagged diagonal bolts spread across the whole sky.
    private static func lightningBoltCells() -> [(x: Int, y: Int)] {
        var cells: [(x: Int, y: Int)] = []
        for start in [2, 12, 22] {
            var x = start
            for y in 0..<20 {
                cells.append((x: x, y: y))
                cells.append((x: x + 1, y: y))
                switch y % 3 {
                case 0: x += 2
                case 1: x += 1
                default: x -= 1
                }
            }
        }
        return cells
    }
}
