import Foundation

// MARK: - Airdramon (Champion) - serpentine dragon, wings

extension SpriteCatalog {

    static func airdramonFrames(
        _ kind: AnimationKind
    ) -> [SpriteFrame] {
        let idle1 = SpriteFrame(rows: [
            0x0000, //  ................
            0x0F00, //  ....####........  head
            0x1F80, //  ...######.......
            0x1D80, //  ...###.##.......  eye
            0x0F00, //  ....####........
            0x0780, //  .....####.......  neck
            0x0FC0, //  ....######......
            0x3FF0, //  ..##########....  wings
            0x7FF8, //  .############...
            0xC00C, //  ##..........##..  wing tips
            0x0FC0, //  ....######......  body
            0x07E0, //  .....######.....
            0x03F0, //  ......######....  tail curving
            0x01F8, //  .......######...
            0x00FC, //  ........######..
            0x0038  //  ..........###...  tail tip
        ])

        let idle2 = SpriteFrame(rows: [
            0x0000,
            0x0F00, 0x1F80, 0x1D80, 0x0F00,
            0x0780,
            0x0FC0,
            0x7FF8, //  wings up
            0x3FF0,
            0x0FC0,
            0x0FC0,
            0x07E0,
            0x03F0,
            0x01F8,
            0x00FC,
            0x0038
        ])

        // Spinning Needle (God Tornado) — head lunges, spiral wind marks
        let attack1 = SpriteFrame(rows: [
            0x0000, //  ................
            0x0F00, //  ....####........  head
            0x1F80, //  ...######.......
            0x1D80, //  ...###.##.......  eye
            0x0F80, //  ....#####.......  mouth open wide
            0x0780, //  .....####.......  neck
            0x0FC0, //  ....######......
            0x7FF8, //  .############...  wings fully spread
            0xFFFC, //  ##############..
            0xC00C, //  ##..........##..  wing tips
            0x0FC0, //  ....######......
            0x07E0, //  .....######.....
            0x03F0, //  ......######....
            0x01F8, //  .......######...
            0x00FC, //  ........######..
            0x0038  //  ..........###...
        ])

        let attack2 = SpriteFrame(rows: [
            0x0000, //  ................
            0x0F00, //  ....####........
            0x1F80, //  ...######.......
            0x1D82, //  ...###.##.....#.  wind mark
            0x0F84, //  ....#####....#..  spinning
            0x078A, //  .....####...#.#.  X pattern
            0x0FC4, //  ....######...#..  wind mark
            0x7FFA, //  .############.#.  spinning
            0xFFFC, //  ##############..
            0xC00C, //  ##..........##..
            0x0FC0, //  ....######......
            0x07E0, //  .....######.....
            0x03F0, //  ......######....
            0x01F8, //  .......######...
            0x00FC, //  ........######..
            0x0038  //  ..........###...
        ])

        // Side-walk: serpentine dragon side, wings, long body
        let sideWalk1 = SpriteFrame(rows: [
            0x0000, //  ................
            0x0F00, //  ....####........  head
            0x1F80, //  ...######.......
            0x1D80, //  ...###.##.......  eye
            0x0F00, //  ....####........
            0x0780, //  .....####.......  neck
            0x0FC0, //  ....######......
            0x1FC0, //  ...#######......  wing
            0x3FE0, //  ..#########.....  wing spread
            0x0FC0, //  ....######......  body
            0x07E0, //  .....######.....
            0x03F0, //  ......######....  tail
            0x01F8, //  .......######...
            0x00FC, //  ........######..
            0x007C, //  .........#####..
            0x0018  //  ...........##...  tail tip
        ])

        let sideWalk2 = SpriteFrame(rows: [
            0x0000, //  ................
            0x0F00, //  ....####........  head
            0x1F80, //  ...######.......
            0x1D80, //  ...###.##.......  eye
            0x0F00, //  ....####........
            0x0780, //  .....####.......  neck
            0x0FC0, //  ....######......
            0x3FE0, //  ..#########.....  wing up
            0x1FC0, //  ...#######......
            0x0FC0, //  ....######......  body
            0x07E0, //  .....######.....
            0x03F0, //  ......######....  tail
            0x01F8, //  .......######...
            0x00FC, //  ........######..
            0x007C, //  .........#####..
            0x0018  //  ...........##...  tail tip
        ])

        switch kind {
        case .idle, .walk:
            return [idle1, idle2]
        case .sideWalk:
            return [sideWalk1, sideWalk2]
        case .happy, .eat, .sleep:
            return defaultAnimationFromIdle(idle1, idle2, kind)
        case .attack:
            return [
                idle1.shiftedRight(1),
                attack1,
                attack2,
                idle1
            ]
        case .refuse:
            return defaultAnimationFromIdle(idle1, idle2, kind)
        }
    }
}
