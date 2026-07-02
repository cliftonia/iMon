import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers
import UserNotifications

/// Renders the pet in its home LCD scene — grid, ground and a day or night sky —
/// to a PNG and wraps it as a notification attachment, so a reminder's long-look
/// shows the pet where it actually lives rather than a bare green swatch or the
/// app icon. Uses CoreGraphics + ImageIO (watchOS lacks UIKit's renderer).
nonisolated enum NotificationSpriteRenderer {

    // The LCD is a 32x20 cell grid; each cell renders at `pixelScale` points.
    private static let columns = 32
    private static let rows = 20
    private static let pixelScale = 12

    /// Where the pet rests on the grid — matching the on-screen idle offset.
    private static let petOffsetX = 8

    /// A screen colour in device RGB — a named type so the palette constants and
    /// draw helpers stay readable (and clear of the tuple-size lint).
    private struct RGB {
        let r: CGFloat
        let g: CGFloat
        let b: CGFloat
    }

    // Daytime: black pixels on the signature green. Night (light off): white
    // pixels on a near-black screen, mirroring the LCD's classic palette.
    private static let dayBackground = RGB(r: CGFloat(0x8B) / 255, g: CGFloat(0xAC) / 255, b: CGFloat(0x6E) / 255)
    private static let dayPixel = RGB(r: 0, g: 0, b: 0)
    private static let nightBackground = RGB(r: 0.07, g: 0.07, b: 0.07)
    private static let nightPixel = RGB(r: 1, g: 1, b: 1)

    static func attachment(for species: PetSpecies, isNight: Bool) -> UNNotificationAttachment? {
        guard let url = renderPNG(for: species, isNight: isNight) else { return nil }
        return try? UNNotificationAttachment(
            identifier: "sprite-\(species.rawValue)-\(isNight ? "night" : "day")", url: url
        )
    }

    private static func renderPNG(for species: PetSpecies, isNight: Bool) -> URL? {
        let width = columns * pixelScale
        let height = rows * pixelScale

        guard let context = CGContext(
            data: nil, width: width, height: height,
            bitsPerComponent: 8, bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return nil }

        // Draw top-down (as the LCD does) by flipping CoreGraphics' bottom-left
        // origin, so a grid cell (x, y) maps straight through with no per-cell flip.
        context.translateBy(x: 0, y: CGFloat(height))
        context.scaleBy(x: 1, y: -1)

        drawScene(for: species, isNight: isNight, in: context)
        return finalize(context)
    }

    private static func finalize(_ context: CGContext) -> URL? {
        guard let image = context.makeImage() else { return nil }
        // A unique file per render: the system moves the attachment into its own
        // store, so reusing one path would strand later notifications of the same pet.
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("skykin-\(UUID().uuidString).png")
        guard let destination = CGImageDestinationCreateWithURL(
            url as CFURL, UTType.png.identifier as CFString, 1, nil
        ) else { return nil }
        CGImageDestinationAddImage(destination, image, nil)
        guard CGImageDestinationFinalize(destination) else { return nil }
        return url
    }

    // MARK: - Scene

    private static func drawScene(for species: PetSpecies, isNight: Bool, in context: CGContext) {
        let background = isNight ? nightBackground : dayBackground
        let pixel = isNight ? nightPixel : dayPixel

        fill(background, alpha: 1, in: context)
        context.fill(CGRect(x: 0, y: 0, width: columns * pixelScale, height: rows * pixelScale))

        drawGrid(pixel: pixel, in: context)
        drawGround(pixel: pixel, in: context)
        if isNight { drawNightSky(pixel: pixel, in: context) }
        drawPet(species, pixel: pixel, in: context)
    }

    /// The faint 4-cell backdrop grid, matching the on-screen LCD.
    private static func drawGrid(pixel: RGB, in context: CGContext) {
        fill(pixel, alpha: 0.06, in: context)
        let thickness: CGFloat = 1
        for col in stride(from: 0, through: columns, by: 4) {
            context.fill(CGRect(
                x: CGFloat(col * pixelScale), y: 0, width: thickness, height: CGFloat(rows * pixelScale)
            ))
        }
        for row in stride(from: 0, through: rows, by: 4) {
            context.fill(CGRect(
                x: 0, y: CGFloat(row * pixelScale), width: CGFloat(columns * pixelScale), height: thickness
            ))
        }
    }

    /// The ground band and the scattered grass tufts sitting just above it.
    private static func drawGround(pixel: RGB, in context: CGContext) {
        fill(pixel, alpha: 0.12, in: context)
        context.fill(CGRect(
            x: 0, y: 19 * pixelScale, width: columns * pixelScale, height: pixelScale
        ))
        fill(pixel, alpha: 0.10, in: context)
        for col in [1, 5, 10, 15, 21, 26, 30] {
            fillCell(x: col, y: 18, in: context)
        }
    }

    /// A full moon in the top-right with a few stars kept clear of the pet.
    private static func drawNightSky(pixel: RGB, in context: CGContext) {
        fill(pixel, alpha: 1, in: context)
        for disc in moonDisc {
            fillCell(x: moonCenter.x + disc.0, y: moonCenter.y + disc.1, in: context)
        }
        for star in starSpots {
            fillCell(x: star.0, y: star.1, in: context)
        }
    }

    private static func drawPet(_ species: PetSpecies, pixel: RGB, in context: CGContext) {
        let frame = SpriteCatalog.frames(for: species, kind: .idle).first ?? .empty
        fill(pixel, alpha: 1, in: context)
        for y in 0..<SpriteFrame.size {
            for x in 0..<SpriteFrame.size where frame.pixel(x: x, y: y) {
                fillCell(x: x + petOffsetX, y: y, in: context)
            }
        }
    }

    // MARK: - Primitives

    private static func fill(_ color: RGB, alpha: CGFloat, in context: CGContext) {
        context.setFillColor(red: color.r, green: color.g, blue: color.b, alpha: alpha)
    }

    private static func fillCell(x: Int, y: Int, in context: CGContext) {
        context.fill(CGRect(
            x: x * pixelScale, y: y * pixelScale, width: pixelScale, height: pixelScale
        ))
    }

    // The moon disc and star field, sharing the LCD's own cell layout.
    private static let moonCenter = (x: 26, y: 4)
    private static let moonDisc: [(Int, Int)] = [
        (-1, -3), (0, -3), (1, -3),
        (-2, -2), (-1, -2), (0, -2), (1, -2), (2, -2),
        (-3, -1), (-2, -1), (-1, -1), (0, -1), (1, -1), (2, -1), (3, -1),
        (-3, 0), (-2, 0), (-1, 0), (0, 0), (1, 0), (2, 0), (3, 0),
        (-3, 1), (-2, 1), (-1, 1), (0, 1), (1, 1), (2, 1), (3, 1),
        (-2, 2), (-1, 2), (0, 2), (1, 2), (2, 2),
        (-1, 3), (0, 3), (1, 3)
    ]
    private static let starSpots = [(3, 2), (6, 5), (4, 9), (2, 13), (30, 11), (28, 14)]
}
