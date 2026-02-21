import Foundation

/// Pixel art sprite data for all Digimon species.
/// Each sprite is a 16x16 monochrome bitmap encoded as 16 UInt16 rows (MSB = left).
nonisolated enum SpriteCatalog {

    nonisolated enum AnimationKind: CaseIterable, Sendable {
        case idle
        case walk
        case sideWalk
        case happy
        case eat
        case sleep
        case attack
        case refuse
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
        case .sideWalk:
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
        case .refuse:
            duration = 0.15
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
        if kind == .refuse {
            let idle = frames(for: species, kind: .idle)
            let base = idle[0]
            return [
                base.shiftedLeft(1),
                base.shiftedRight(1),
                base.shiftedLeft(1),
                base
            ]
        }
        return switch species {
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

// MARK: - Species Projectile

extension SpriteCatalog {

    /// Species-specific projectile traveling left-to-right.
    static func projectile(
        for species: DigimonSpecies,
        high: Bool
    ) -> SpriteAnimation {
        let shape = projectileShape(for: species)
        let base = projectileFrame(shape: shape, high: high)
        return SpriteAnimation(
            frames: [
                base,
                base.shiftedRight(4),
                base.shiftedRight(8),
                base.shiftedRight(12)
            ],
            frameDuration: 0.15,
            loops: false
        )
    }

    private static func projectileShape(
        for species: DigimonSpecies
    ) -> (UInt16, UInt16, UInt16, UInt16) {
        switch species {
        case .botamon, .koromon:
            // Bubble — small round
            (0x6000, 0xF000, 0xF000, 0x6000)
        case .agumon:
            // Pepper Breath — fireball
            (0x4000, 0xE000, 0xF000, 0x6000)
        case .betamon:
            // Electric Shock — zigzag bolt
            (0xC000, 0x6000, 0xC000, 0x4000)
        case .greymon:
            // Nova Blast — large fireball
            (0xE000, 0xF000, 0xF000, 0xE000)
        case .tyrannomon:
            // Fire Breath — flame
            (0x4000, 0xE000, 0x7000, 0x2000)
        case .devimon:
            // Death Claw — slash marks
            (0x9000, 0x6000, 0x6000, 0x9000)
        case .meramon:
            // Burning Fist — flame fist
            (0x6000, 0xF000, 0xE000, 0x4000)
        case .airdramon:
            // Spinning Needle — wind spiral
            (0xA000, 0x4000, 0xA000, 0x4000)
        case .seadramon:
            // Ice Arrow — diamond crystal
            (0x4000, 0xE000, 0xE000, 0x4000)
        case .numemon:
            // Poop Toss — poop glob
            (0x4000, 0xC000, 0xE000, 0x6000)
        case .metalGreymon:
            // Giga Blaster — missile
            (0x2000, 0xF000, 0xF000, 0x2000)
        case .mamemon:
            // Smiley Bomb — bomb
            (0x2000, 0x6000, 0xF000, 0x6000)
        case .monzaemon:
            // Hearts Attack — heart
            (0xA000, 0xE000, 0x4000, 0x0000)
        }
    }

    private static func projectileFrame(
        shape: (UInt16, UInt16, UInt16, UInt16),
        high: Bool
    ) -> SpriteFrame {
        let z: UInt16 = 0x0000
        if high {
            return SpriteFrame(rows: [
                z, z, z,
                shape.0, shape.1, shape.2, shape.3,
                z, z, z, z, z, z, z, z, z
            ])
        } else {
            return SpriteFrame(rows: [
                z, z, z, z, z, z, z, z,
                shape.0, shape.1, shape.2, shape.3,
                z, z, z, z
            ])
        }
    }
}

// MARK: - Default Animation Helpers

extension SpriteCatalog {

    /// Generates 4-frame animations from idle frames for species
    /// without dedicated animation data, using sprite transformations.
    static func defaultAnimationFromIdle(
        _ idle1: SpriteFrame,
        _ idle2: SpriteFrame,
        _ kind: AnimationKind
    ) -> [SpriteFrame] {
        switch kind {
        case .idle, .walk:
            return [idle1, idle2]

        case .sideWalk:
            return defaultSideWalkFromIdle(idle1, idle2)

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

        case .refuse:
            // Head shake: left → right → left → idle
            return [
                idle1.shiftedLeft(1),
                idle1.shiftedRight(1),
                idle1.shiftedLeft(1),
                idle1
            ]
        }
    }

    /// Generates a simple 2-frame side-walk from idle frames
    /// using horizontal shift as a placeholder side profile.
    static func defaultSideWalkFromIdle(
        _ idle1: SpriteFrame,
        _ idle2: SpriteFrame
    ) -> [SpriteFrame] {
        [idle1.shiftedLeft(1), idle2.shiftedLeft(1)]
    }
}
