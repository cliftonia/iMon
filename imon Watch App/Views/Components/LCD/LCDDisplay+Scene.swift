import SwiftUI

// MARK: - Scene Backdrop

extension LCDDisplay {

    func drawGrid(
        in context: GraphicsContext,
        size: CGSize,
        pixelWidth: CGFloat,
        pixelHeight: CGFloat
    ) {
        let gridColor = basePixelColor.opacity(isDarkScreen ? 0.24 : 0.06)

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

    func drawGround(
        in context: GraphicsContext,
        size: CGSize,
        pixelWidth: CGFloat,
        pixelHeight: CGFloat
    ) {
        let groundColor = basePixelColor.opacity(isDarkScreen ? 0.34 : 0.12)

        let groundY = 19.0 * pixelHeight
        let groundLine = Path(
            CGRect(
                x: 0, y: groundY,
                width: size.width, height: pixelHeight
            )
        )
        context.fill(groundLine, with: .color(groundColor))

        let tufts: [Int] = [1, 5, 10, 15, 21, 26, 30]
        let tuftColor = basePixelColor.opacity(isDarkScreen ? 0.28 : 0.10)
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
}
