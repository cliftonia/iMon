import Foundation

// MARK: - Devimon (Champion) - winged demon, tall and thin

extension SpriteCatalog {

    static func devimonFrames(
        _ kind: AnimationKind
    ) -> [SpriteFrame] {
        let idle1 = SpriteFrame(rows: [
            0x0380, //  ......###.......  horns
            0x07C0, //  .....#####......
            0x0FE0, //  ....#######.....  head
            0x0DA0, //  ....##.##.#.....  eyes
            0x0FE0, //  ....#######.....
            0x03C0, //  ......####......  neck
            0x07E0, //  .....######.....  body
            0x0FF0, //  ....########....
            0x3FFC, //  ..############..  wings spread
            0x7FFE, //  .##############.
            0x4FF2, //  .#..########..#.  wing tips
            0x07E0, //  .....######.....
            0x03C0, //  ......####......  waist
            0x03C0, //  ......####......
            0x0240, //  ......#..#......  legs
            0x0660  //  .....##..##.....  feet
        ])

        let idle2 = SpriteFrame(rows: [
            0x0380, 0x07C0, 0x0FE0, 0x0DA0, 0x0FE0,
            0x03C0, 0x07E0, 0x0FF0,
            0x7FFE, //  wings up
            0x3FFC,
            0x0FF0,
            0x07E0,
            0x03C0,
            0x03C0,
            0x0240,
            0x0660
        ])

        // Death Claw (Touch of Evil) — wings spread, claws slash forward
        let attack1 = SpriteFrame(rows: [
            0x0380, //  ......###.......  horns
            0x07C0, //  .....#####......
            0x0FE0, //  ....#######.....  head
            0x0DA0, //  ....##.##.#.....  eyes
            0x0FE0, //  ....#######.....
            0x03C0, //  ......####......  neck
            0x0FF0, //  ....########....  body leaning forward
            0x1FF8, //  ...##########...
            0x7FFE, //  .##############.  wings wide
            0xFFFF, //  ################  wings fully spread
            0x4FF2, //  .#..########..#.  wing tips
            0x0FE0, //  ....#######.....  arms raised
            0x03C0, //  ......####......
            0x03C0, //  ......####......
            0x0240, //  ......#..#......
            0x0660  //  .....##..##.....
        ])

        let attack2 = SpriteFrame(rows: [
            0x0380, //  ......###.......  horns
            0x07C0, //  .....#####......
            0x0FE0, //  ....#######.....
            0x0DA0, //  ....##.##.#.....
            0x0FE4, //  ....#######..#..  claw scratch 1
            0x03C8, //  ......####..#...  diagonal slash
            0x0FF4, //  ....########.#..  claw mark
            0x1FE8, //  ...########.#...  slash
            0x7FF4, //  .###########.#..  claw scratch 2
            0xFFF8, //  #############...
            0x4FF4, //  .#..########.#..  scratch 3
            0x07E8, //  .....######.#...  diagonal
            0x03D4, //  ......####.#.#..  claw tips
            0x03C0, //  ......####......
            0x0240, //  ......#..#......
            0x0660  //  .....##..##.....
        ])

        switch kind {
        case .idle, .walk:
            return [idle1, idle2]
        case .happy, .eat, .sleep:
            return defaultAnimationFromIdle(idle1, idle2, kind)
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
