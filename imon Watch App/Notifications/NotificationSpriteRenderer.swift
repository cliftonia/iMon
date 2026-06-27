import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers
import UserNotifications

/// Renders a species' idle sprite to a PNG and wraps it as a notification
/// attachment, so a reminder's long-look shows the actual pet rather than the
/// generic app icon. Uses CoreGraphics + ImageIO (watchOS lacks UIKit's renderer).
nonisolated enum NotificationSpriteRenderer {

    /// The LCD palette: black pixels on the signature green.
    private static let background = (r: CGFloat(0x8B) / 255, g: CGFloat(0xAC) / 255, b: CGFloat(0x6E) / 255)
    private static let pixelScale = 12

    static func attachment(for species: PetSpecies) -> UNNotificationAttachment? {
        guard let url = renderPNG(for: species) else { return nil }
        return try? UNNotificationAttachment(
            identifier: "sprite-\(species.rawValue)", url: url
        )
    }

    private static func renderPNG(for species: PetSpecies) -> URL? {
        let frame = SpriteCatalog.frames(for: species, kind: .idle).first ?? .empty
        let dimension = SpriteFrame.size * pixelScale

        guard let context = CGContext(
            data: nil, width: dimension, height: dimension,
            bitsPerComponent: 8, bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return nil }

        context.setFillColor(red: background.r, green: background.g, blue: background.b, alpha: 1)
        context.fill(CGRect(x: 0, y: 0, width: dimension, height: dimension))
        context.setFillColor(red: 0, green: 0, blue: 0, alpha: 1)

        for y in 0..<SpriteFrame.size {
            for x in 0..<SpriteFrame.size where frame.pixel(x: x, y: y) {
                // CoreGraphics' origin is bottom-left; the sprite is top-down.
                let flippedY = SpriteFrame.size - 1 - y
                context.fill(CGRect(
                    x: x * pixelScale, y: flippedY * pixelScale,
                    width: pixelScale, height: pixelScale
                ))
            }
        }

        guard let image = context.makeImage() else { return nil }
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("skykin-\(species.rawValue).png")
        guard let destination = CGImageDestinationCreateWithURL(
            url as CFURL, UTType.png.identifier as CFString, 1, nil
        ) else { return nil }
        CGImageDestinationAddImage(destination, image, nil)
        guard CGImageDestinationFinalize(destination) else { return nil }
        return url
    }
}
