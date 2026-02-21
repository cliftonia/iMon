import CoreGraphics
import Foundation

/// Converts a SpriteFrame bitmap into a CGImage for display in SwiftUI.
/// On pixels render as black (opaque), off pixels as transparent.
nonisolated enum PixelArtRenderer {

    /// Render a SpriteFrame to a 16x16 CGImage.
    /// Each logical pixel maps to one image pixel; scaling is handled by
    /// SwiftUI's `.interpolation(.none)` modifier at the call site.
    static func render(_ frame: SpriteFrame) -> CGImage? {
        let size = SpriteFrame.size
        let bytesPerPixel = 4
        let bytesPerRow = size * bytesPerPixel

        var pixelData = [UInt8](
            repeating: 0,
            count: size * size * bytesPerPixel
        )

        for y in 0..<size {
            for x in 0..<size {
                let offset = (y * size + x) * bytesPerPixel
                if frame.pixel(x: x, y: y) {
                    pixelData[offset] = 0       // R
                    pixelData[offset + 1] = 0   // G
                    pixelData[offset + 2] = 0   // B
                    pixelData[offset + 3] = 255 // A
                } else {
                    pixelData[offset + 3] = 0   // A = transparent
                }
            }
        }

        let colorSpace = CGColorSpaceCreateDeviceRGB()

        return pixelData.withUnsafeMutableBytes { buffer in
            guard let baseAddress = buffer.baseAddress else {
                return nil
            }
            guard let context = CGContext(
                data: baseAddress,
                width: size,
                height: size,
                bitsPerComponent: 8,
                bytesPerRow: bytesPerRow,
                space: colorSpace,
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            ) else {
                return nil
            }
            return context.makeImage()
        }
    }
}
