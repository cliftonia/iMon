import Foundation
import Testing
@testable import imon_Watch_App

@Suite("SpriteFrame interior holes")
struct SpriteFrameTests {

    /// A solid 8-wide block (cols 4...11) spanning rows 4...11, with one pixel
    /// punched out at (7, 7) - a fully enclosed "eye".
    private static func blockWithHole() -> SpriteFrame {
        var rows = [UInt16](repeating: 0, count: 16)
        for y in 4...11 { rows[y] = 0x0FF0 }
        rows[7] = 0x0EF0 // clear x = 7
        return SpriteFrame(rows: rows)
    }

    @Test func `an enclosed gap is reported as a hole`() {
        let holes = Self.blockWithHole().interiorHoles()
        #expect(holes.pixel(x: 7, y: 7))
        // Nothing else is a hole - body pixels and outside stay clear.
        var count = 0
        for y in 0..<16 {
            for x in 0..<16 where holes.pixel(x: x, y: y) { count += 1 }
        }
        #expect(count == 1)
    }

    @Test func `a gap that opens to the border is not a hole`() {
        // Carve a channel from the gap straight up to the top edge, so it is
        // reachable from outside (like the space between two legs).
        var rows = [UInt16](repeating: 0, count: 16)
        for y in 4...11 { rows[y] = 0x0FF0 }
        for y in 4...7 { rows[y] = 0x0EF0 } // open x = 7 up through the border
        let holes = SpriteFrame(rows: rows).interiorHoles()
        for y in 0..<16 {
            for x in 0..<16 {
                #expect(!holes.pixel(x: x, y: y))
            }
        }
    }

    @Test func `a real creature's eyes are detected as holes`() {
        // Emberkin idle row 4 is 0x0A80 = `....#.#.#` (cols 4,6,8 lit), so the
        // enclosed eye gaps sit at x = 5 and x = 7, walled in by the body.
        let idle = SpriteCatalog.emberkinFrames(.idle)[0]
        let holes = idle.interiorHoles()
        #expect(holes.pixel(x: 5, y: 4))
        #expect(holes.pixel(x: 7, y: 4))
    }
}
