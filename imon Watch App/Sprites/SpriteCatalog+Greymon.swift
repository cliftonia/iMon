import Foundation

// MARK: - Greymon (Champion) - large horned dinosaur

extension SpriteCatalog {

    // Greymon: big T-rex shape, helmet/horn, powerful build

    static func greymonFrames(
        _ kind: AnimationKind
    ) -> [SpriteFrame] {
        let idle1 = SpriteFrame(rows: [
            0x0100, //  .......#........  horn
            0x0380, //  ......###.......  horn base
            0x07C0, //  .....#####......  helmet
            0x0FE0, //  ....#######.....  head
            0x0DA0, //  ....##.##.#.....  eye + stripe
            0x0FE0, //  ....#######.....
            0x0FC0, //  ....######......  jaw
            0x07C0, //  .....#####......  neck
            0x0FE0, //  ....#######.....  body
            0x3FF8, //  ..###########...  wide body
            0x7FFC, //  .#############..
            0x5FFC, //  .#.###########..  arm
            0x3FF8, //  ..###########...
            0x0FE0, //  ....#######.....  legs
            0x0920, //  ....#..#..#.....
            0x1930  //  ...##..#..##....  feet
        ])

        let idle2 = SpriteFrame(rows: [
            0x0100,
            0x0380,
            0x07C0,
            0x0FE0,
            0x0DA0,
            0x0FE0,
            0x0FC0,
            0x07C0,
            0x0FE0,
            0x3FF8,
            0x7FFC,
            0x5FFC,
            0x3FF8,
            0x0FE0,
            0x1220, //  ...#..#..#......  walking
            0x1230  //  ...#..#..##.....
        ])

        let happy1 = SpriteFrame(rows: [
            0x0100, 0x0380, 0x07C0,
            0x0FE0,
            0x0AA0, //  ....#.#.#.#.....  ^_^ eyes
            0x0FE0,
            0x0DC0, //  ....##.###......  smile
            0x07C0,
            0x0FE0,
            0x3FF8, 0x7FFC, 0x5FFC,
            0x3FF8,
            0x0FE0,
            0x0920,
            0x1930
        ])

        let happy2 = SpriteFrame(rows: [
            0x0000,
            0x0100, 0x0380, 0x07C0,
            0x0FE0,
            0x0AA0,
            0x0FE0,
            0x0DC0,
            0x07C0,
            0x0FE0,
            0x3FF8, 0x7FFC, 0x5FFC,
            0x3FF8,
            0x0FE0,
            0x0920
        ])

        let eat1 = SpriteFrame(rows: [
            0x0100, 0x0380, 0x07C0,
            0x0FE0,
            0x0DA0,
            0x0FE0,
            0x0E40, //  ....###..#......  mouth open
            0x07C0,
            0x0FE0,
            0x3FF8, 0x7FFC, 0x5FFC,
            0x3FF8,
            0x0FE0,
            0x0920,
            0x1930
        ])

        let eat2 = SpriteFrame(rows: [
            0x0100, 0x0380, 0x07C0,
            0x0FE0,
            0x0DA0,
            0x0FE0,
            0x0FC0, //  mouth closed
            0x07C0,
            0x0FE0,
            0x3FF8, 0x7FFC, 0x5FFC,
            0x3FF8,
            0x0FE0,
            0x0920,
            0x1930
        ])

        // Nova Blast attack
        let attack1 = SpriteFrame(rows: [
            0x0100, 0x0380, 0x07C0,
            0x0FE0, 0x0DA0, 0x0FE0,
            0x0E00, //  ....###.........  mouth wide
            0x07C0,
            0x0FE0,
            0x3FF8, 0x7FFC, 0x5FFC,
            0x3FF8,
            0x0FE0,
            0x0920,
            0x1930
        ])

        let attack2 = SpriteFrame(rows: [
            0x0100, 0x0380, 0x07C0,
            0x0FE0, 0x0DA0, 0x0FE0,
            0x0E1E, //  ....###....####.  fire blast
            0x07DF, //  .....#####.#####
            0x0FE0,
            0x3FF8, 0x7FFC, 0x5FFC,
            0x3FF8,
            0x0FE0,
            0x0920,
            0x1930
        ])

        let sleep1 = SpriteFrame(rows: [
            0x0038, //  ..........###...  Z
            0x0010, //  ...........#....
            0x0380, 0x07C0,
            0x0FE0,
            0x0B60, //  ....#.##.##.....  closed eyes
            0x0FE0,
            0x0FC0,
            0x07C0,
            0x0FE0,
            0x3FF8, 0x7FFC,
            0x3FF8,
            0x3FF8,
            0x0FE0,
            0x0920
        ])

        let sleep2 = SpriteFrame(rows: [
            0x001C, //  ............###.  Z higher
            0x0038,
            0x0010,
            0x07C0,
            0x0FE0,
            0x0B60,
            0x0FE0,
            0x0FC0,
            0x07C0,
            0x0FE0,
            0x3FF8, 0x7FFC,
            0x3FF8,
            0x3FF8,
            0x0FE0,
            0x0920
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
                attack2.overlaying(SharedSprites.impactBurst)
            ]
        }
    }
}
