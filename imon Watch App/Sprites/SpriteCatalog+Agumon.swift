import Foundation

// MARK: - Agumon (Rookie) - small upright dinosaur

extension SpriteCatalog {

    // Agumon: upright bipedal dinosaur with short arms, tail, claws
    //
    //         .....###........    head top
    //         ....#####.......
    //         ....##.##.......    eye
    //         ....#####.......    jaw
    //         ....####........
    //         ...######.......    body
    //         ..########......
    //         .#.######.......    arm/claw
    //         ...######.......
    //         ....####........
    //         ....#..#........    legs
    //         ...##..##.......    feet

    static func agumonFrames(
        _ kind: AnimationKind
    ) -> [SpriteFrame] {
        let idle1 = SpriteFrame(rows: [
            0x0000, //  ................
            0x0000, //  ................
            0x0700, //  .....###........
            0x0F80, //  ....#####.......
            0x0D80, //  ....##.##.......
            0x0F80, //  ....#####.......
            0x0F00, //  ....####........
            0x1FC0, //  ...#######......
            0x3F80, //  ..#######.......
            0x5F80, //  .#.######.......
            0x1F80, //  ...######.......
            0x0F00, //  ....####........
            0x0F00, //  ....####........
            0x0900, //  ....#..#........
            0x1980, //  ...##..##.......
            0x0000  //  ................
        ])

        let idle2 = SpriteFrame(rows: [
            0x0000, //  ................
            0x0000, //  ................
            0x0700, //  .....###........
            0x0F80, //  ....#####.......
            0x0D80, //  ....##.##.......
            0x0F80, //  ....#####.......
            0x0F00, //  ....####........
            0x1FC0, //  ...#######......
            0x3F80, //  ..#######.......
            0x5F80, //  .#.######.......
            0x1F80, //  ...######.......
            0x0F00, //  ....####........
            0x0F00, //  ....####........
            0x1200, //  ...#..#.........
            0x1300, //  ...#..##........
            0x0000  //  ................
        ])

        let walk1 = SpriteFrame(rows: [
            0x0000, 0x0000,
            0x0700, 0x0F80, 0x0D80, 0x0F80,
            0x0F00,
            0x1FC0,
            0x3F80,
            0x5F80,
            0x1F80,
            0x0F00,
            0x0F00,
            0x0900,
            0x1980,
            0x0000
        ])

        let walk2 = SpriteFrame(rows: [
            0x0000, 0x0000,
            0x0700, 0x0F80, 0x0D80, 0x0F80,
            0x0F00,
            0x1FC0,
            0x3F80,
            0x5F80,
            0x1F80,
            0x0F00,
            0x0F00,
            0x1200,
            0x1300,
            0x0000
        ])

        let happy1 = SpriteFrame(rows: [
            0x0000, 0x0000,
            0x0700,
            0x0F80,
            0x0A80, //  ....#.#.#.......  ^_^ eyes
            0x0F80,
            0x0D00, //  ....##.#........  smile
            0x1FC0,
            0x3F80,
            0x5F80,
            0x1F80,
            0x0F00,
            0x0F00,
            0x0900,
            0x1980,
            0x0000
        ])

        let happy2 = SpriteFrame(rows: [
            0x0000,
            0x0700,
            0x0F80,
            0x0A80,
            0x0F80,
            0x0D00,
            0x1FC0,
            0x3F80,
            0x5F80,
            0x1F80,
            0x0F00,
            0x0F00,
            0x0900,
            0x1980,
            0x0000, 0x0000
        ])

        let eat1 = SpriteFrame(rows: [
            0x0000, 0x0000,
            0x0700,
            0x0F80,
            0x0D80,
            0x0F80,
            0x0E00, //  ....###.........  mouth open
            0x1FC0,
            0x3F80,
            0x5F80,
            0x1F80,
            0x0F00,
            0x0F00,
            0x0900,
            0x1980,
            0x0000
        ])

        let eat2 = SpriteFrame(rows: [
            0x0000, 0x0000,
            0x0700,
            0x0F80,
            0x0D80,
            0x0F80,
            0x0F00, //  mouth closed
            0x1FC0,
            0x3F80,
            0x5F80,
            0x1F80,
            0x0F00,
            0x0F00,
            0x0900,
            0x1980,
            0x0000
        ])

        let sleep1 = SpriteFrame(rows: [
            0x0000,
            0x0038, //  ..........###...  Z
            0x0010, //  ...........#....
            0x0700,
            0x0F80,
            0x0B80, //  ....#.###.......  closed eyes
            0x0F80,
            0x0F00,
            0x1FC0,
            0x3F80,
            0x1F80,
            0x1F80,
            0x0F00,
            0x0F00,
            0x0900,
            0x1980
        ])

        let sleep2 = SpriteFrame(rows: [
            0x0038,
            0x0010,
            0x0000,
            0x0700,
            0x0F80,
            0x0B80,
            0x0F80,
            0x0F00,
            0x1FC0,
            0x3F80,
            0x1F80,
            0x1F80,
            0x0F00,
            0x0F00,
            0x0900,
            0x1980
        ])

        // Pepper Breath attack - mouth open wide, fireball in front
        let attack1 = SpriteFrame(rows: [
            0x0000, 0x0000,
            0x0700,
            0x0F80,
            0x0D80,
            0x0FC0, //  ....######......  head forward
            0x0E00, //  ....###.........  mouth open
            0x1FC0,
            0x3F80,
            0x5F80,
            0x1F80,
            0x0F00,
            0x0F00,
            0x0900,
            0x1980,
            0x0000
        ])

        let attack2 = SpriteFrame(rows: [
            0x0000, 0x0000,
            0x0700,
            0x0F80,
            0x0D80,
            0x0FC6, //  ....######...##.  fireball
            0x0E0F, //  ....###.....####  fireball
            0x1FC6, //  ...#######...##.
            0x3F80,
            0x5F80,
            0x1F80,
            0x0F00,
            0x0F00,
            0x0900,
            0x1980,
            0x0000
        ])

        // Side-walk: upright dinosaur side view, tail behind, two legs
        let sideWalk1 = SpriteFrame(rows: [
            0x0000, //  ................
            0x0000, //  ................
            0x0F00, //  ....####........  head round
            0x1F80, //  ...######.......
            0x1B80, //  ...##.###.......  eye
            0x1F80, //  ...######.......
            0x0F00, //  ....####........  jaw
            0x0F00, //  ....####........  neck
            0x1F80, //  ...######.......  body
            0x1F80, //  ...######.......
            0x0FC0, //  ....######......  tail side
            0x0F00, //  ....####........
            0x0F00, //  ....####........  legs
            0x0900, //  ....#..#........  leg stride
            0x1100, //  ...#...#........  feet apart
            0x0000  //  ................
        ])

        let sideWalk2 = SpriteFrame(rows: [
            0x0000, //  ................
            0x0000, //  ................
            0x0F00, //  ....####........  head round
            0x1F80, //  ...######.......
            0x1B80, //  ...##.###.......  eye
            0x1F80, //  ...######.......
            0x0F00, //  ....####........  jaw
            0x0F00, //  ....####........  neck
            0x1F80, //  ...######.......  body
            0x1F80, //  ...######.......
            0x0FC0, //  ....######......  tail side
            0x0F00, //  ....####........
            0x0F00, //  ....####........  legs
            0x1200, //  ...#..#.........  legs together
            0x1200, //  ...#..#.........  feet
            0x0000  //  ................
        ])

        switch kind {
        case .idle:
            return [idle1, idle2]
        case .walk:
            return [
                walk1,
                walk1.shiftedDown(1),
                walk2,
                walk2.shiftedDown(1)
            ]
        case .sideWalk:
            return [sideWalk1, sideWalk2]
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
        case .refuse:
            return defaultAnimationFromIdle(idle1, idle2, kind)
        }
    }
}
