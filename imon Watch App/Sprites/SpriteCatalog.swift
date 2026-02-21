import Foundation

// swiftlint:disable file_length

/// Pixel art sprite data for all Digimon species.
/// Each sprite is a 16x16 monochrome bitmap encoded as 16 UInt16 rows (MSB = left).
nonisolated enum SpriteCatalog {

    nonisolated enum AnimationKind: CaseIterable, Sendable {
        case idle
        case walk
        case happy
        case eat
        case sleep
        case attack
    }

    static func animation(
        for species: DigimonSpecies,
        kind: AnimationKind
    ) -> SpriteAnimation {
        let frames = self.frames(for: species, kind: kind)

        let duration: TimeInterval
        let loops: Bool

        switch kind {
        case .idle:
            duration = 0.5
            loops = true
        case .walk:
            duration = 0.35
            loops = true
        case .happy:
            duration = 0.25
            loops = true
        case .eat:
            duration = 0.3
            loops = false
        case .sleep:
            duration = 0.9
            loops = true
        case .attack:
            duration = 0.2
            loops = false
        }

        return SpriteAnimation(
            frames: frames,
            frameDuration: duration,
            loops: loops
        )
    }
}

// MARK: - Frame Dispatch

extension SpriteCatalog {

    private static func frames(
        for species: DigimonSpecies,
        kind: AnimationKind
    ) -> [SpriteFrame] {
        switch species {
        case .botamon: botamonFrames(kind)
        case .koromon: koromonFrames(kind)
        case .agumon: agumonFrames(kind)
        case .betamon: betamonFrames(kind)
        case .greymon: greymonFrames(kind)
        case .tyrannomon: tyrannomonFrames(kind)
        case .devimon: devimonFrames(kind)
        case .meramon: meramonFrames(kind)
        case .airdramon: airdramonFrames(kind)
        case .seadramon: seadramonFrames(kind)
        case .numemon: numemonFrames(kind)
        case .metalGreymon: metalGreymonFrames(kind)
        case .mamemon: mamemonFrames(kind)
        case .monzaemon: monzaemonFrames(kind)
        }
    }
}

// MARK: - Botamon (Fresh / Baby I) - tiny black blob with eyes

extension SpriteCatalog {

    // Botamon: a small round blob, centered low in the 16x16 grid.
    //
    // Frame 1 (resting):          Frame 2 (bounce):
    //   Row 0:  ................     ................
    //   Row 1:  ................     ................
    //   Row 2:  ................     ................
    //   Row 3:  ................     ................
    //   Row 4:  ................     ................
    //   Row 5:  ................     ......####......
    //   Row 6:  ......####......     ....########....
    //   Row 7:  ....########....     ...##.####.##...
    //   Row 8:  ...##########...     ...##########...
    //   Row 9:  ..##.####.###..     ...##########...
    //   Row10:  ..############.     ....########....
    //   Row11:  ..############.     .....######.....
    //   Row12:  ...##########...     ................
    //   Row13:  ....########....     ................
    //   Row14:  ......####......     ................
    //   Row15:  ................     ................

    private static func botamonFrames(
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

    private static func koromonFrames(
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
    //

    private static func agumonFrames(
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

// MARK: - Betamon (Rookie) - amphibian/lizard, low to the ground

extension SpriteCatalog {

    // Betamon: wide frog-like body, fin on back, low stance

    private static func betamonFrames(
        _ kind: AnimationKind
    ) -> [SpriteFrame] {
        let idle1 = SpriteFrame(rows: [
            0x0000, //  ................
            0x0000, //  ................
            0x0000, //  ................
            0x0000, //  ................
            0x0200, //  ......#.........  fin tip
            0x0700, //  .....###........  fin
            0x0F80, //  ....#####.......  head
            0x1FC0, //  ...#######......
            0x3BC0, //  ..###.####......  eye
            0x3FE0, //  ..#########.....
            0x7FF0, //  .###########....  body
            0x7FF0, //  .###########....
            0x3FE0, //  ..#########.....
            0x1FC0, //  ...#######......
            0x1240, //  ...#..#..#.#....  feet
            0x0000  //  ................
        ])

        let idle2 = SpriteFrame(rows: [
            0x0000, 0x0000, 0x0000, 0x0000,
            0x0000,
            0x0200, //  fin tip
            0x0700, //  fin
            0x0F80, //  head
            0x1FC0,
            0x3BC0, //  eye
            0x3FE0,
            0x7FF0, //  body
            0x7FF0,
            0x3FE0,
            0x1FC0,
            0x1240  //  feet
        ])

        switch kind {
        case .idle, .walk: return [idle1, idle2]
        case .happy, .eat, .sleep, .attack:
            return defaultAnimationFromIdle(idle1, idle2, kind)
        }
    }
}

// MARK: - Greymon (Champion) - large horned dinosaur

extension SpriteCatalog {

    // Greymon: big T-rex shape, helmet/horn, powerful build

    private static func greymonFrames(
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

// MARK: - Tyrannomon (Champion) - red dinosaur, bulky

extension SpriteCatalog {

    private static func tyrannomonFrames(
        _ kind: AnimationKind
    ) -> [SpriteFrame] {
        let idle1 = SpriteFrame(rows: [
            0x0000, //  ................
            0x0000, //  ................
            0x07C0, //  .....#####......  head
            0x0FE0, //  ....#######.....
            0x0DA0, //  ....##.##.#.....  eye
            0x0FE0, //  ....#######.....
            0x07C0, //  .....#####......  neck
            0x0FE0, //  ....#######.....  body
            0x1FF0, //  ...#########....
            0x5FF0, //  .#.#########....  arms
            0x1FF0, //  ...#########....
            0x0FE0, //  ....#######.....
            0x0FE0, //  ....#######.....  tail
            0x0920, //  ....#..#..#.....  legs
            0x1930, //  ...##..#..##....  feet
            0x0000  //  ................
        ])

        let idle2 = SpriteFrame(rows: [
            0x0000, 0x0000,
            0x07C0, 0x0FE0, 0x0DA0, 0x0FE0,
            0x07C0, 0x0FE0, 0x1FF0, 0x5FF0,
            0x1FF0, 0x0FE0, 0x0FE0,
            0x1220, //  ...#..#..#......  alt legs
            0x1230, //  ...#..#..##.....
            0x0000
        ])

        switch kind {
        case .idle, .walk: return [idle1, idle2]
        case .happy, .eat, .sleep, .attack:
            return defaultAnimationFromIdle(idle1, idle2, kind)
        }
    }
}

// MARK: - Devimon (Champion) - winged demon, tall and thin

extension SpriteCatalog {

    private static func devimonFrames(
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

        switch kind {
        case .idle, .walk: return [idle1, idle2]
        case .happy, .eat, .sleep, .attack:
            return defaultAnimationFromIdle(idle1, idle2, kind)
        }
    }
}

// MARK: - Meramon (Champion) - humanoid fire creature

extension SpriteCatalog {

    private static func meramonFrames(
        _ kind: AnimationKind
    ) -> [SpriteFrame] {
        let idle1 = SpriteFrame(rows: [
            0x0100, //  .......#........  flame tip
            0x0380, //  ......###.......  flame
            0x07C0, //  .....#####......  flame/head
            0x0FE0, //  ....#######.....  head
            0x0DA0, //  ....##.##.#.....  eyes
            0x07C0, //  .....#####......
            0x03C0, //  ......####......  neck
            0x0FF0, //  ....########....  body
            0x1FF8, //  ...##########...
            0x3FFC, //  ..############..  arms out
            0x0FF0, //  ....########....
            0x07E0, //  .....######.....
            0x07E0, //  .....######.....
            0x0240, //  ......#..#......  legs
            0x0660, //  .....##..##.....  feet
            0x0000  //  ................
        ])

        let idle2 = SpriteFrame(rows: [
            0x0280, //  ......#.#.......  flickering flame
            0x05C0, //  .....#.###......
            0x0FE0, //  ....#######.....
            0x0FE0, //  ....#######.....
            0x0DA0, //  ....##.##.#.....
            0x07C0, //  .....#####......
            0x03C0, //  ......####......
            0x0FF0, //  ....########....
            0x1FF8, //  ...##########...
            0x3FFC, //  ..############..
            0x0FF0, //  ....########....
            0x07E0, //  .....######.....
            0x07E0, //  .....######.....
            0x0240, //  ......#..#......
            0x0660, //  .....##..##.....
            0x0000
        ])

        switch kind {
        case .idle, .walk: return [idle1, idle2]
        case .happy, .eat, .sleep, .attack:
            return defaultAnimationFromIdle(idle1, idle2, kind)
        }
    }
}

// MARK: - Airdramon (Champion) - serpentine dragon, wings

extension SpriteCatalog {

    private static func airdramonFrames(
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

        switch kind {
        case .idle, .walk: return [idle1, idle2]
        case .happy, .eat, .sleep, .attack:
            return defaultAnimationFromIdle(idle1, idle2, kind)
        }
    }
}

// MARK: - Seadramon (Champion) - sea serpent, long neck

extension SpriteCatalog {

    private static func seadramonFrames(
        _ kind: AnimationKind
    ) -> [SpriteFrame] {
        let idle1 = SpriteFrame(rows: [
            0x0000, //  ................
            0x0780, //  .....####.......  head
            0x0FC0, //  ....######......
            0x0DC0, //  ....##.###......  eye
            0x0FC0, //  ....######......  jaw
            0x07C0, //  .....#####......  neck
            0x03C0, //  ......####......
            0x03C0, //  ......####......
            0x07E0, //  .....######.....  body thickens
            0x0FF0, //  ....########....
            0x0FF0, //  ....########....
            0x07E0, //  .....######.....
            0x03F0, //  ......######....  tail
            0x01F8, //  .......######...
            0x00F8, //  ........#####...
            0x0030  //  ..........##....  tail tip
        ])

        let idle2 = SpriteFrame(rows: [
            0x0000,
            0x0780, 0x0FC0, 0x0DC0, 0x0FC0,
            0x07C0,
            0x03E0, //  ......#####.....  neck sway
            0x03E0,
            0x07E0,
            0x0FF0, 0x0FF0,
            0x07E0,
            0x03F0,
            0x01F8,
            0x00F8,
            0x0030
        ])

        switch kind {
        case .idle, .walk: return [idle1, idle2]
        case .happy, .eat, .sleep, .attack:
            return defaultAnimationFromIdle(idle1, idle2, kind)
        }
    }
}

// MARK: - Numemon (Champion) - slug/blob, simple shape

extension SpriteCatalog {

    private static func numemonFrames(
        _ kind: AnimationKind
    ) -> [SpriteFrame] {
        let idle1 = SpriteFrame(rows: [
            0x0000, //  ................
            0x0000, //  ................
            0x0000, //  ................
            0x0000, //  ................
            0x0000, //  ................
            0x0180, //  .......##.......  eye stalks
            0x0180, //  .......##.......
            0x07E0, //  .....######.....  head
            0x0FF0, //  ....########....
            0x1BD8, //  ...##.####.##...  eyes
            0x1FF8, //  ...##########...
            0x1C38, //  ...###....###...  mouth
            0x1FF8, //  ...##########...
            0x0FF0, //  ....########....
            0x07E0, //  .....######.....  slime trail
            0x0000  //  ................
        ])

        let idle2 = SpriteFrame(rows: [
            0x0000, 0x0000, 0x0000, 0x0000,
            0x0180, //  eye stalks
            0x0180,
            0x0000,
            0x07E0,
            0x0FF0,
            0x1BD8,
            0x1FF8,
            0x1C38,
            0x1FF8,
            0x0FF0,
            0x0FF0, //  wider at bottom (squish)
            0x0000
        ])

        switch kind {
        case .idle, .walk: return [idle1, idle2]
        case .happy, .eat, .sleep, .attack:
            return defaultAnimationFromIdle(idle1, idle2, kind)
        }
    }
}

// MARK: - MetalGreymon (Ultimate) - cyborg dinosaur, massive

extension SpriteCatalog {

    private static func metalGreymonFrames(
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

        switch kind {
        case .idle, .walk: return [idle1, idle2]
        case .happy, .eat, .sleep, .attack:
            return defaultAnimationFromIdle(idle1, idle2, kind)
        }
    }
}

// MARK: - Mamemon (Ultimate) - round body, big glove hand

extension SpriteCatalog {

    private static func mamemonFrames(
        _ kind: AnimationKind
    ) -> [SpriteFrame] {
        let idle1 = SpriteFrame(rows: [
            0x0000, //  ................
            0x0000, //  ................
            0x03C0, //  ......####......  head
            0x07E0, //  .....######.....
            0x0FF0, //  ....########....
            0x0DB0, //  ....##.##.##....  eyes
            0x0FF0, //  ....########....
            0x0FF0, //  ....########....  body
            0x1FF8, //  ...##########...
            0x1FF8, //  ...##########...
            0xFFF0, //  ############....  big glove arm
            0xFFF0, //  ############....
            0x1FF8, //  ...##########...
            0x0FF0, //  ....########....
            0x0480, //  .....#..#.......  legs
            0x0CC0  //  ....##..##......  feet
        ])

        let idle2 = SpriteFrame(rows: [
            0x0000, 0x0000,
            0x03C0, 0x07E0, 0x0FF0,
            0x0DB0, 0x0FF0, 0x0FF0,
            0x1FF8, 0x1FF8,
            0x0FFF, //  ....############  glove other side
            0x0FFF,
            0x1FF8,
            0x0FF0,
            0x0480,
            0x0CC0
        ])

        switch kind {
        case .idle, .walk: return [idle1, idle2]
        case .happy, .eat, .sleep, .attack:
            return defaultAnimationFromIdle(idle1, idle2, kind)
        }
    }
}

// MARK: - Monzaemon (Ultimate) - teddy bear, heart on belly

extension SpriteCatalog {

    private static func monzaemonFrames(
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

        switch kind {
        case .idle, .walk: return [idle1, idle2]
        case .happy, .eat, .sleep, .attack:
            return defaultAnimationFromIdle(idle1, idle2, kind)
        }
    }
}

// MARK: - Default Animation Helpers

extension SpriteCatalog {

    /// Generates 4-frame animations from idle frames for species
    /// without dedicated animation data, using sprite transformations.
    private static func defaultAnimationFromIdle(
        _ idle1: SpriteFrame,
        _ idle2: SpriteFrame,
        _ kind: AnimationKind
    ) -> [SpriteFrame] {
        switch kind {
        case .idle, .walk:
            return [idle1, idle2]

        case .happy:
            // Bounce: crouch → jump → peak → land with dust
            return [
                idle1.shiftedDown(1),
                idle1.shiftedUp(2),
                idle1.shiftedUp(1),
                idle1.overlaying(SharedSprites.landingDust)
            ]

        case .eat:
            // Chomp: lean → bite → chew → lean back
            return [
                idle1.shiftedLeft(1),
                idle2.shiftedLeft(1),
                idle1.shiftedLeft(1),
                idle1
            ]

        case .sleep:
            // Breathing with Z's cycling at different heights
            return [
                idle1.overlaying(SharedSprites.sleepZ1),
                idle1.overlaying(SharedSprites.sleepZ2),
                idle2.overlaying(SharedSprites.sleepZ3),
                idle2.overlaying(SharedSprites.sleepZ2)
            ]

        case .attack:
            // Strike: windup → lunge → impact burst → return
            return [
                idle1.shiftedRight(1),
                idle1.shiftedLeft(2),
                idle1.shiftedLeft(1)
                    .overlaying(SharedSprites.impactBurst),
                idle1
            ]
        }
    }
}

// swiftlint:enable file_length
