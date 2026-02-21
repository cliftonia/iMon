import Foundation

// MARK: - Koromon (In-Training / Baby II) - round with floppy ears

extension SpriteCatalog {

    // Koromon: ball shape with two pointy ear/horn flaps on top, wide mouth
    //
    //          ..#........#..        ears
    //          .##........##.
    //          .###.####.###.
    //          ..############
    //          ...##########.
    //          ..##.####.##..        eyes
    //          ..############
    //          ..##..##..##..        mouth open
    //          ..############
    //          ...##########.
    //          ....########..
    //          .....######...

    static func koromonFrames(
        _ kind: AnimationKind
    ) -> [SpriteFrame] {
        let idle1 = SpriteFrame(rows: [
            0x0000, //  ................
            0x0000, //  ................
            0x0000, //  ................
            0x2008, //  ..#..........#..
            0x3018, //  ..##.........##.
            0x3C78, //  ..####....####..
            0x1FF0, //  ...#########....
            0x1FF8, //  ...##########...
            0x37B8, //  ..##.####.###..
            0x3FF8, //  ..###########..
            0x3018, //  ..##.......##..
            0x3FF8, //  ..###########..
            0x1FF0, //  ...#########....
            0x0FE0, //  ....#######.....
            0x07C0, //  .....#####......
            0x0000  //  ................
        ])

        let idle2 = SpriteFrame(rows: [
            0x0000, //  ................
            0x0000, //  ................
            0x2008, //  ..#..........#..
            0x3018, //  ..##.........##.
            0x3C78, //  ..####....####..
            0x1FF0, //  ...#########....
            0x1FF8, //  ...##########...
            0x37B8, //  ..##.####.###..
            0x3FF8, //  ..###########..
            0x3018, //  ..##.......##..
            0x3FF8, //  ..###########..
            0x1FF0, //  ...#########....
            0x0FE0, //  ....#######.....
            0x07C0, //  .....#####......
            0x0000, //  ................
            0x0000  //  ................
        ])

        let happy1 = SpriteFrame(rows: [
            0x0000, 0x0000, 0x0000,
            0x2008,
            0x3018,
            0x3C78,
            0x1FF0,
            0x1FF8,
            0x3498, //  ..##.#..#..##..  ^_^ eyes
            0x3FF8,
            0x3C78, //  ..####...####..  smile
            0x3FF8,
            0x1FF0,
            0x0FE0,
            0x07C0,
            0x0000
        ])

        let happy2 = SpriteFrame(rows: [
            0x0000, 0x0000,
            0x2008,
            0x3018,
            0x3C78,
            0x1FF0,
            0x1FF8,
            0x3498,
            0x3FF8,
            0x3C78,
            0x3FF8,
            0x1FF0,
            0x0FE0,
            0x07C0,
            0x0000, 0x0000
        ])

        let eat1 = SpriteFrame(rows: [
            0x0000, 0x0000, 0x0000,
            0x2008, 0x3018, 0x3C78,
            0x1FF0, 0x1FF8,
            0x37B8,
            0x3FF8,
            0x33D8, //  ..##..####.##..  mouth open
            0x3FF8,
            0x1FF0, 0x0FE0, 0x07C0,
            0x0000
        ])

        let eat2 = SpriteFrame(rows: [
            0x0000, 0x0000, 0x0000,
            0x2008, 0x3018, 0x3C78,
            0x1FF0, 0x1FF8,
            0x37B8,
            0x3FF8,
            0x3FF8, //  mouth closed
            0x3FF8,
            0x1FF0, 0x0FE0, 0x07C0,
            0x0000
        ])

        let sleep1 = SpriteFrame(rows: [
            0x0000, 0x0000, 0x001C,
            0x0018, 0x0000,
            0x3C78,
            0x1FF0, 0x1FF8,
            0x3DB8, //  closed eyes
            0x3FF8, 0x3FF8, 0x3FF8,
            0x1FF0, 0x0FE0, 0x07C0,
            0x0000
        ])

        let sleep2 = SpriteFrame(rows: [
            0x0000, 0x001C, 0x0000,
            0x0018, 0x0000,
            0x3C78,
            0x1FF0, 0x1FF8,
            0x3DB8,
            0x3FF8, 0x3FF8, 0x3FF8,
            0x1FF0, 0x0FE0, 0x07C0,
            0x0000
        ])

        let attack1 = SpriteFrame(rows: [
            0x0000, 0x0000, 0x0000,
            0x2008, 0x3018, 0x3C78,
            0x1FF0, 0x1FF8,
            0x37B8,
            0x3FF8,
            0x3018, //  mouth wide open
            0x3FF8,
            0x1FF0,
            0x0FE0,
            0x87C2, //  #....#####....#.  impact lines
            0x0000
        ])

        let attack2 = SpriteFrame(rows: [
            0x0000, 0x0000,
            0x2008, 0x3018, 0x3C78,
            0x1FF0, 0x1FF8,
            0x37B8,
            0x3FF8,
            0x3018,
            0x3FF8,
            0x1FF0,
            0x0FE0,
            0x07C0,
            0x4004, //  .#............#.
            0x0000
        ])

        // Side-walk: ball with one ear visible from side
        let sideWalk1 = SpriteFrame(rows: [
            0x0000, //  ................
            0x0000, //  ................
            0x0000, //  ................
            0x2000, //  ..#.............  one ear
            0x3000, //  ..##............
            0x3C00, //  ..####..........
            0x1FF0, //  ...#########....
            0x1FF8, //  ...##########...
            0x37B8, //  ..##.####.###..   eye
            0x3FF8, //  ..###########..
            0x3018, //  ..##.......##..   mouth
            0x3FF8, //  ..###########..
            0x1FF0, //  ...#########....
            0x0FE0, //  ....#######.....
            0x07C0, //  .....#####......
            0x0000  //  ................
        ])

        let sideWalk2 = SpriteFrame(rows: [
            0x0000, //  ................
            0x0000, //  ................
            0x2000, //  ..#.............  one ear
            0x3000, //  ..##............
            0x3C00, //  ..####..........
            0x1FF0, //  ...#########....
            0x1FF8, //  ...##########...
            0x37B8, //  ..##.####.###..   eye
            0x3FF8, //  ..###########..
            0x3018, //  ..##.......##..   mouth
            0x3FF8, //  ..###########..
            0x1FF0, //  ...#########....
            0x0FE0, //  ....#######.....
            0x07C0, //  .....#####......
            0x0000, //  ................
            0x0000  //  ................
        ])

        switch kind {
        case .idle, .walk:
            return [idle1, idle2]
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
                idle1
            ]
        case .refuse:
            return defaultAnimationFromIdle(idle1, idle2, kind)
        }
    }
}
