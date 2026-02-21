import Foundation

// MARK: - Monzaemon (Ultimate) - teddy bear, heart on belly

extension SpriteCatalog {

    static func monzaemonFrames(
        _ kind: AnimationKind
    ) -> [SpriteFrame] {
        let idle1 = SpriteFrame(rows: [
            0x0000, //  ................
            0x1188, //  ...#...##...#...  ears
            0x1188, //  ...#...##...#...
            0x0FF0, //  ....########....  head
            0x1FF8, //  ...##########...
            0x1BD8, //  ...##.####.##...  eyes (button)
            0x0FF0, //  ....########....
            0x0CE0, //  ....##..###.....  mouth (stitched)
            0x0FF0, //  ....########....  body
            0x1FF8, //  ...##########...
            0x3FFC, //  ..############..  wide body
            0x3A5C, //  ..###.#..#.###..  heart on belly
            0x3FFC, //  ..############..
            0x1FF8, //  ...##########...
            0x0990, //  ....#..##..#....  legs
            0x1998  //  ...##..##..##...  feet
        ])

        let idle2 = SpriteFrame(rows: [
            0x1188, //  ears
            0x1188,
            0x0FF0, 0x1FF8,
            0x1BD8,
            0x0FF0,
            0x0CE0,
            0x0FF0,
            0x1FF8,
            0x3FFC,
            0x3A5C, //  heart
            0x3FFC,
            0x1FF8,
            0x0FF0,
            0x0990,
            0x1998
        ])

        // Hearts Attack (Lovely Attack) — arms reach forward, hearts fly out
        let attack1 = SpriteFrame(rows: [
            0x0000, //  ................
            0x1188, //  ...#...##...#...  ears
            0x1188, //  ...#...##...#...
            0x0FF0, //  ....########....  head
            0x1FF8, //  ...##########...
            0x1BD8, //  ...##.####.##...  eyes
            0x0FF0, //  ....########....
            0x0CE0, //  ....##..###.....  mouth
            0x1FF0, //  ...#########....  body shifted left (reaching)
            0x3FF8, //  ..###########...  arms forward
            0x7FFC, //  .#############..
            0x7A5C, //  .####.#..#.###..  heart on belly
            0x3FFC, //  ..############..
            0x1FF8, //  ...##########...
            0x0990, //  ....#..##..#....
            0x1998  //  ...##..##..##...
        ])

        let attack2 = SpriteFrame(rows: [
            0x0000, //  ................
            0x1188, //  ...#...##...#...
            0x1188, //  ...#...##...#...
            0x0FF0, //  ....########....
            0x1FFE, //  ...############.  heart 1 flying
            0x1BDA, //  ...##.####.##.#.  heart shape
            0x0FFE, //  ....###########.
            0x0CE0, //  ....##..###.....
            0x0FF0, //  ....########....
            0x1FF8, //  ...##########...  heart 2 flying
            0x3FFC, //  ..############..
            0x3A5A, //  ..###.#..#.#.#.  heart shape
            0x3FFE, //  ..#############.
            0x1FF8, //  ...##########...
            0x0990, //  ....#..##..#....
            0x1998  //  ...##..##..##...
        ])

        // Side-walk: teddy bear side, one ear, round body, stubby limbs
        let sideWalk1 = SpriteFrame(rows: [
            0x0000, //  ................
            0x1800, //  ...##...........  one ear
            0x1800, //  ...##...........
            0x0FC0, //  ....######......  head
            0x1FE0, //  ...########.....
            0x1BE0, //  ...##.#####.....  eye (button)
            0x0FE0, //  ....#######.....
            0x0CE0, //  ....##..###.....  stitched mouth
            0x0FE0, //  ....#######.....  body
            0x1FF0, //  ...#########....
            0x3FF0, //  ..##########....
            0x3AF0, //  ..###.#.####....  heart
            0x3FF0, //  ..##########....
            0x1FE0, //  ...########.....
            0x0D80, //  ....##.##.......  legs stride
            0x1180  //  ...#...##.......  feet apart
        ])

        let sideWalk2 = SpriteFrame(rows: [
            0x0000, //  ................
            0x1800, //  ...##...........  one ear
            0x1800, //  ...##...........
            0x0FC0, //  ....######......  head
            0x1FE0, //  ...########.....
            0x1BE0, //  ...##.#####.....  eye (button)
            0x0FE0, //  ....#######.....
            0x0CE0, //  ....##..###.....  stitched mouth
            0x0FE0, //  ....#######.....  body
            0x1FF0, //  ...#########....
            0x3FF0, //  ..##########....
            0x3AF0, //  ..###.#.####....  heart
            0x3FF0, //  ..##########....
            0x1FE0, //  ...########.....
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
                idle1
            ]
        case .refuse:
            return defaultAnimationFromIdle(idle1, idle2, kind)
        }
    }
}
