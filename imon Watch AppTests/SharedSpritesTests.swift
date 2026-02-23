import Testing
@testable import imon_Watch_App

@Suite("SharedSprites")
struct SharedSpritesTests {

    // MARK: - Shower Head

    @Test
    func `water drops frames have shower head in top rows`() {
        let frame1 = SharedSprites.waterDrops1
        let frame2 = SharedSprites.waterDrops2

        // Row 0: pipe stem
        #expect(frame1.rows[0] == 0x0700)
        #expect(frame2.rows[0] == 0x0700)

        // Row 1: head plate
        #expect(frame1.rows[1] == 0x1FC0)
        #expect(frame2.rows[1] == 0x1FC0)

        // Row 2: nozzle holes
        #expect(frame1.rows[2] == 0x1540)
        #expect(frame2.rows[2] == 0x1540)
    }

    @Test
    func `water drops stay within LCD bounds at offset 20`() {
        let frames = [
            SharedSprites.waterDrops1,
            SharedSprites.waterDrops2
        ]
        for frame in frames {
            for row in frame.rows {
                // At offsetX=20, col 12+ is off-screen (32-wide LCD)
                // Bits 3..0 correspond to cols 12-15
                let offScreenBits: UInt16 = 0x000F
                #expect(row & offScreenBits == 0)
            }
        }
    }

    // MARK: - Satisfaction Heart

    @Test
    func `satisfaction heart stays within LCD bounds at offset 20`() {
        let heart = SharedSprites.satisfactionHeart
        for row in heart.rows {
            let offScreenBits: UInt16 = 0x000F
            #expect(row & offScreenBits == 0)
        }
    }

    @Test
    func `satisfaction heart has pixel data`() {
        let heart = SharedSprites.satisfactionHeart
        let hasPixels = heart.rows.contains { $0 != 0 }
        #expect(hasPixels)
    }

    // MARK: - Clean Sparkle

    @Test
    func `clean sparkle frames stay within LCD bounds`() {
        let frames = [
            SharedSprites.cleanSparkle1,
            SharedSprites.cleanSparkle2
        ]
        for frame in frames {
            for row in frame.rows {
                let offScreenBits: UInt16 = 0x000F
                #expect(row & offScreenBits == 0)
            }
        }
    }
}
