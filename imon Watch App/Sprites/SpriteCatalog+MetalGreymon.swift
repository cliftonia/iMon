import Foundation

// MARK: - MetalGreymon (Ultimate) - cyborg dinosaur, massive

extension SpriteCatalog {

    static func metalGreymonFrames(
        _ kind: AnimationKind
    ) -> [SpriteFrame] {
        let idle1 = SpriteFrame(rows: [
            0x0180, //  .......##.......  horn
            0x03C0, //  ......####......
            0x07E0, //  .....######.....  helmet
            0x0FF0, //  ....########....  head
            0x0DB0, //  ....##.##.##....  eye + visor
            0x0FF0, //  ....########....
            0x07E0, //  .....######.....  neck
            0x1FF8, //  ...##########...  body + metal
            0x3FFC, //  ..############..
            0x7FFE, //  .##############.  wings/arms
            0xFFFF, //  ################  widest
            0x7FFE, //  .##############.
            0x3FFC, //  ..############..
            0x1FF8, //  ...##########...  legs
            0x0DB0, //  ....##.##.##....
            0x1DB8  //  ...###.##.###...  feet
        ])

        let idle2 = SpriteFrame(rows: [
            0x0180, 0x03C0, 0x07E0, 0x0FF0,
            0x0DB0, 0x0FF0, 0x07E0,
            0x1FF8, 0x3FFC,
            0xFFFF, //  wings
            0x7FFE,
            0x7FFE,
            0x3FFC,
            0x1FF8,
            0x1230,
            0x1AB8  //  alt feet
        ])

        // Giga Blaster (Trident Arm) — braces, missile/beam fires
        let attack1 = SpriteFrame(rows: [
            0x0180, //  .......##.......  horn
            0x03C0, //  ......####......
            0x07E0, //  .....######.....  helmet
            0x0FF0, //  ....########....  head
            0x0DB0, //  ....##.##.##....  eye
            0x0FF0, //  ....########....
            0x07E0, //  .....######.....  neck
            0x1FF8, //  ...##########...  body braced
            0x3FFC, //  ..############..
            0xFFFF, //  ################  wings/arms spread wider
            0xFFFF, //  ################
            0x7FFE, //  .##############.
            0x3FFC, //  ..############..
            0x1FF8, //  ...##########...
            0x0DB0, //  ....##.##.##....
            0x1DB8  //  ...###.##.###...
        ])

        let attack2 = SpriteFrame(rows: [
            0x0180, //  .......##.......
            0x03C0, //  ......####......
            0x07E0, //  .....######.....
            0x0FF0, //  ....########....
            0x0DB0, //  ....##.##.##....
            0x0FF0, //  ....########....
            0x07E0, //  .....######.....
            0x1FFC, //  ...############.  missile extending
            0x3FFF, //  ..##############  beam/missile
            0xFFFE, //  ###############.  arrow shape
            0xFFFF, //  ################
            0x7FFE, //  .##############.
            0x3FFC, //  ..############..
            0x1FF8, //  ...##########...
            0x0DB0, //  ....##.##.##....
            0x1DB8  //  ...###.##.###...
        ])

        // Side-walk: cyborg dinosaur side, metal arm, wings, massive
        let sideWalk1 = SpriteFrame(rows: [
            0x0300, //  ......##........  horn
            0x0700, //  .....###........  helmet
            0x0F80, //  ....#####.......  head
            0x1FC0, //  ...#######......
            0x1BC0, //  ...##.####......  visor eye
            0x1FC0, //  ...#######......
            0x0F80, //  ....#####.......  neck
            0x1FC0, //  ...#######......  body + metal
            0x3FE0, //  ..#########.....
            0x7FE0, //  .##########.....  wing
            0x3FE0, //  ..#########.....
            0x1FC0, //  ...#######......
            0x1FC0, //  ...#######......
            0x0F80, //  ....#####.......  legs
            0x0D80, //  ....##.##.......  stride
            0x1180  //  ...#...##.......  feet apart
        ])

        let sideWalk2 = SpriteFrame(rows: [
            0x0300, //  ......##........  horn
            0x0700, //  .....###........  helmet
            0x0F80, //  ....#####.......  head
            0x1FC0, //  ...#######......
            0x1BC0, //  ...##.####......  visor eye
            0x1FC0, //  ...#######......
            0x0F80, //  ....#####.......  neck
            0x1FC0, //  ...#######......  body + metal
            0x3FE0, //  ..#########.....
            0x7FE0, //  .##########.....  wing
            0x3FE0, //  ..#########.....
            0x1FC0, //  ...#######......
            0x1FC0, //  ...#######......
            0x0F80, //  ....#####.......  legs
            0x1280, //  ...#..#.#.......  together
            0x1280  //  ...#..#.#.......  feet
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
                attack2.overlaying(SharedSprites.impactBurst)
            ]
        }
    }
}
