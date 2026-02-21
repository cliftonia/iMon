import SwiftUI

struct LCDDisplay: View {

    let leftSprite: SpriteFrame
    let rightSprite: SpriteFrame?
    let poopCount: Int
    let stinkPhase: Int

    init(
        leftSprite: SpriteFrame,
        rightSprite: SpriteFrame? = nil,
        poopCount: Int = 0,
        stinkPhase: Int = 0
    ) {
        self.leftSprite = leftSprite
        self.rightSprite = rightSprite
        self.poopCount = poopCount
        self.stinkPhase = stinkPhase
    }

    var body: some View {
        Canvas { context, size in
            let pixelWidth = size.width / 32
            let pixelHeight = size.height / 16

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
                offsetX: 8,
                pixelWidth: pixelWidth,
                pixelHeight: pixelHeight
            )

            if let rightSprite {
                drawSprite(
                    rightSprite,
                    in: context,
                    offsetX: 20,
                    pixelWidth: pixelWidth,
                    pixelHeight: pixelHeight
                )
            }

            drawPoop(
                in: context,
                pixelWidth: pixelWidth,
                pixelHeight: pixelHeight
            )
        }
        .background(Color("LCDBackground"))
        .aspectRatio(2, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .accessibilityHidden(true)
    }

    // MARK: - Background

    private func drawGrid(
        in context: GraphicsContext,
        size: CGSize,
        pixelWidth: CGFloat,
        pixelHeight: CGFloat
    ) {
        let gridColor = Color("LCDPixelOn").opacity(0.06)

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
        for row in stride(from: 0, through: 16, by: 4) {
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
        let groundColor = Color("LCDPixelOn").opacity(0.12)

        let groundY = 15.0 * pixelHeight
        let groundLine = Path(
            CGRect(
                x: 0, y: groundY,
                width: size.width, height: pixelHeight
            )
        )
        context.fill(groundLine, with: .color(groundColor))

        let tufts: [Int] = [1, 5, 10, 15, 21, 26, 30]
        let tuftColor = Color("LCDPixelOn").opacity(0.10)
        for col in tufts {
            let rect = CGRect(
                x: Double(col) * pixelWidth,
                y: 14.0 * pixelHeight,
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
        pixelWidth: CGFloat,
        pixelHeight: CGFloat
    ) {
        let pixelColor: Color = Color("LCDPixelOn")

        for y in 0..<SpriteFrame.size {
            for x in 0..<SpriteFrame.size {
                guard sprite.pixel(x: x, y: y) else { continue }
                let rect = CGRect(
                    x: Double(x + offsetX) * pixelWidth,
                    y: Double(y) * pixelHeight,
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
        let color = Color("LCDPixelOn")

        // Poop pile positions on the 32x16 LCD
        let bases: [(x: Int, y: Int)] = [
            (25, 10), (29, 10),
            (25, 13), (29, 13)
        ]

        // Classic poop pile: tip + body + base
        let pilePixels: [(dx: Int, dy: Int)] = [
            (1, 0),
            (0, 1), (1, 1), (2, 1),
            (1, 2)
        ]

        for i in 0..<min(poopCount, 4) {
            let base = bases[i]
            for p in pilePixels {
                drawPixel(
                    x: base.x + p.dx,
                    y: base.y + p.dy,
                    color: color,
                    in: context,
                    pixelWidth: pixelWidth,
                    pixelHeight: pixelHeight
                )
            }
        }

        // Stink wavy lines above poop area
        let stinkColor = Color("LCDPixelOn").opacity(0.7)
        let stinkPixels: [(x: Int, y: Int)]
        if stinkPhase % 2 == 0 {
            stinkPixels = [(26, 8), (28, 7), (30, 8)]
        } else {
            stinkPixels = [(25, 7), (27, 8), (31, 7)]
        }
        for p in stinkPixels {
            drawPixel(
                x: p.x, y: p.y,
                color: stinkColor,
                in: context,
                pixelWidth: pixelWidth,
                pixelHeight: pixelHeight
            )
        }
    }

    private func drawPixel(
        x: Int,
        y: Int,
        color: Color,
        in context: GraphicsContext,
        pixelWidth: CGFloat,
        pixelHeight: CGFloat
    ) {
        let rect = CGRect(
            x: Double(x) * pixelWidth,
            y: Double(y) * pixelHeight,
            width: pixelWidth + 0.5,
            height: pixelHeight + 0.5
        )
        context.fill(Path(rect), with: .color(color))
    }
}
