import Foundation

// MARK: - Botamon (Fresh / Baby I) - tiny black blob with eyes

extension SpriteCatalog {

    // Botamon: a small round blob, centered low in the 16x16 grid.
    //
    // Frame 1 (resting):          Frame 2 (bounce):
    //   Row 0:  ................     ................
    //   Row 5:  ................     ......####......
    //   Row 6:  ......####......     ....########....
    //   Row 7:  ....########....     ...##.####.##...
    //   Row 8:  ...##########...     ...##########...
    //   Row 9:  ..##.####.###..     ...##########...
    //   Row10:  ..############.     ....########....
    //   Row11:  ..############.     .....######.....
    //   Row14:  ......####......     ................

    static func botamonFrames(
        _ kind: AnimationKind
    ) -> [SpriteFrame] {
        let idle1 = SpriteFrame(rows: [
            0x0000, //  ................
            0x0000, //  ................
            0x0000, //  ................
            0x0000, //  ................
            0x0000, //  ................
            0x0000, //  ................
            0x03C0, //  ......####......
            0x0FF0, //  ....########....
            0x1FF8, //  ...##########...
            0x37B8, //  ..##.####.###..
            0x3FF8, //  ..###########..
            0x3FF8, //  ..###########..
            0x1FF8, //  ...##########...
            0x0FF0, //  ....########....
            0x03C0, //  ......####......
            0x0000  //  ................
        ])

        let idle2 = SpriteFrame(rows: [
            0x0000, //  ................
            0x0000, //  ................
            0x0000, //  ................
            0x0000, //  ................
            0x0000, //  ................
            0x03C0, //  ......####......
            0x0FF0, //  ....########....
            0x37B8, //  ..##.####.###..
            0x1FF8, //  ...##########...
            0x1FF8, //  ...##########...
            0x0FF0, //  ....########....
            0x07E0, //  .....######.....
            0x0000, //  ................
            0x0000, //  ................
            0x0000, //  ................
            0x0000  //  ................
        ])

        let happy1 = SpriteFrame(rows: [
            0x0000, 0x0000, 0x0000, 0x0000,
            0x0000, 0x0000,
            0x03C0, //  ......####......
            0x0FF0, //  ....########....
            0x1FF8, //  ...##########...
            0x3498, //  ..##.#..#..##..
            0x3FF8, //  ..###########..
            0x3C78, //  ..####...####..  (smile)
            0x1FF8, //  ...##########...
            0x0FF0, //  ....########....
            0x03C0, //  ......####......
            0x0000
        ])

        let happy2 = SpriteFrame(rows: [
            0x0000, 0x0000, 0x0000, 0x0000,
            0x0000,
            0x03C0,
            0x0FF0,
            0x1FF8,
            0x3498, //  eyes
            0x3FF8,
            0x3C78, //  smile
            0x1FF8,
            0x0FF0,
            0x03C0,
            0x0000, 0x0000
        ])

        let eat1 = SpriteFrame(rows: [
            0x0000, 0x0000, 0x0000, 0x0000,
            0x0000, 0x0000,
            0x03C0,
            0x0FF0,
            0x1FF8,
            0x37B8, //  eyes
            0x3FF8,
            0x39F8, //  mouth open ..###..######..
            0x1FF8,
            0x0FF0,
            0x03C0,
            0x0000
        ])

        let eat2 = SpriteFrame(rows: [
            0x0000, 0x0000, 0x0000, 0x0000,
            0x0000, 0x0000,
            0x03C0,
            0x0FF0,
            0x1FF8,
            0x37B8, //  eyes
            0x3E78, //  mouth closed
            0x3FF8,
            0x1FF8,
            0x0FF0,
            0x03C0,
            0x0000
        ])

        let sleep1 = SpriteFrame(rows: [
            0x0000, 0x0000, 0x0000, 0x001C,
            0x0000, 0x0018, 0x0000,
            0x03C0,
            0x0FF0,
            0x1FF8,
            0x3DB8, //  closed eyes --
            0x3FF8,
            0x1FF8,
            0x0FF0,
            0x03C0,
            0x0000
        ])

        let sleep2 = SpriteFrame(rows: [
            0x0000, 0x0000, 0x001C, 0x0000,
            0x0018, 0x0000, 0x0000,
            0x03C0,
            0x0FF0,
            0x1FF8,
            0x3DB8, //  closed eyes
            0x3FF8,
            0x1FF8,
            0x0FF0,
            0x03C0,
            0x0000
        ])

        let attack1 = SpriteFrame(rows: [
            0x0000, 0x0000, 0x0000, 0x0000,
            0x0000, 0x0000,
            0x03C0,
            0x0FF0,
            0x1FF8,
            0x37B8,
            0x3FF8,
            0x3FF8,
            0x1FF8,
            0x0FF0,
            0x43C4, //  .#....####....#.  impact lines
            0x0000
        ])

        let attack2 = SpriteFrame(rows: [
            0x0000, 0x0000, 0x0000, 0x0000,
            0x0000,
            0x03C0,
            0x0FF0,
            0x1FF8,
            0x37B8,
            0x3FF8,
            0x3FF8,
            0x1FF8,
            0x0FF0,
            0x03C0,
            0x8001, //  #..............#  impact lines
            0x0000
        ])

        switch kind {
        case .idle, .walk:
            return [idle1, idle2]
        case .happy:
            return [
                idle1.shiftedDown(1),
                happy1,
                happy2,
                idle1.overlaying(SharedSprites.landingDust)
            ]
        case .eat:
            return [eat1, eat2, eat1, idle1]
        case .sleep:
            return [
                sleep1,
                idle1.overlaying(SharedSprites.sleepZ2),
                sleep2,
                idle2.overlaying(SharedSprites.sleepZ3)
            ]
        case .attack:
            return [
                idle1.shiftedRight(1),
                attack1,
                attack2,
                idle1
            ]
        }
    }
}
