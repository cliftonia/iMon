import Foundation

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
