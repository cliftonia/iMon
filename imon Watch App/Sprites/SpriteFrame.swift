import Foundation

/// A 16x16 1-bit bitmap. Each UInt16 represents one row where MSB = leftmost pixel.
/// Recreates the original 1997 Bandai Digital Monster's monochrome LCD sprite format.
nonisolated struct SpriteFrame: Sendable, Hashable {

    let rows: [UInt16]

    init(rows: [UInt16]) {
        precondition(rows.count == 16, "SpriteFrame must have exactly 16 rows")
        self.rows = rows
    }

    /// Check if pixel at (x, y) is on. x=0 is leftmost, y=0 is topmost.
    func pixel(x: Int, y: Int) -> Bool {
        guard x >= 0, x < Self.size, y >= 0, y < Self.size else { return false }
        return (rows[y] >> (15 - x)) & 1 == 1
    }

    /// Horizontally mirror the sprite (flip left-right).
    func mirrored() -> SpriteFrame {
        let mirroredRows = rows.map { row -> UInt16 in
            var result: UInt16 = 0
            for i in 0..<16 {
                if (row >> i) & 1 == 1 {
                    result |= 1 << (15 - i)
                }
            }
            return result
        }
        return SpriteFrame(rows: mirroredRows)
    }

    /// Shift all pixels up by N rows (bottom fills with empty).
    func shiftedUp(_ n: Int) -> SpriteFrame {
        guard n > 0, n < Self.size else { return self }
        let shifted = Array(rows.suffix(Self.size - n))
            + [UInt16](repeating: 0, count: n)
        return SpriteFrame(rows: shifted)
    }

    /// Shift all pixels down by N rows (top fills with empty).
    func shiftedDown(_ n: Int) -> SpriteFrame {
        guard n > 0, n < Self.size else { return self }
        let shifted = [UInt16](repeating: 0, count: n)
            + Array(rows.prefix(Self.size - n))
        return SpriteFrame(rows: shifted)
    }

    /// Shift all pixels left by N columns.
    func shiftedLeft(_ n: Int) -> SpriteFrame {
        guard n > 0, n < Self.size else { return self }
        return SpriteFrame(rows: rows.map { $0 << n })
    }

    /// Shift all pixels right by N columns.
    func shiftedRight(_ n: Int) -> SpriteFrame {
        guard n > 0, n < Self.size else { return self }
        return SpriteFrame(rows: rows.map { $0 >> n })
    }

    /// Overlay another frame using bitwise OR.
    func overlaying(_ other: SpriteFrame) -> SpriteFrame {
        SpriteFrame(rows: zip(rows, other.rows).map { $0 | $1 })
    }

    static let empty = SpriteFrame(
        rows: [UInt16](repeating: 0, count: 16)
    )

    static let size = 16
}
