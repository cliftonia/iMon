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

    init(
        leftSprite: SpriteFrame,
        rightSprite: SpriteFrame? = nil,
        poopCount: Int = 0,
        stinkPhase: Int = 0,
        lightsOn: Bool = true,
        leftSpriteOffsetX: Int = 8,
        leftSpriteOffsetY: Int = 4,
        rightSpriteOffsetY: Int = 4
    ) {
        self.leftSprite = leftSprite
        self.rightSprite = rightSprite
        self.poopCount = poopCount
        self.stinkPhase = stinkPhase
        self.lightsOn = lightsOn
        self.leftSpriteOffsetX = leftSpriteOffsetX
        self.leftSpriteOffsetY = leftSpriteOffsetY
        self.rightSpriteOffsetY = rightSpriteOffsetY
    }

    // MARK: - Colors

    private var backgroundColor: Color {
        lightsOn ? Color("LCDBackground") : Color(white: 0.07)
    }

    private var basePixelColor: Color {
        lightsOn ? Color("LCDPixelOn") : .white
    }

    var body: some View {
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
        }
        .background(backgroundColor)
        .aspectRatio(32.0 / 20.0, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .accessibilityHidden(true)
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
