import Foundation

/// Pixel art sprite data for all Creature species.
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
        for species: PetSpecies,
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

nonisolated extension SpriteCatalog {

    static func frames(
        for species: PetSpecies,
        kind: AnimationKind
    ) -> [SpriteFrame] {
        let raw = speciesFrames(for: species, kind: kind)
        return kind == .attack ? enhancedAttack(raw) : raw
    }

    private static func speciesFrames(
        for species: PetSpecies,
        kind: AnimationKind
    ) -> [SpriteFrame] {
        return switch species {
        case .dotkin: dotkinFrames(kind)
        case .hopkin: hopkinFrames(kind)
        case .emberkin: emberkinFrames(kind)
        case .marshkin: marshkinFrames(kind)
        case .rexkin: rexkinFrames(kind)
        case .blazekin: blazekinFrames(kind)
        case .dreadkin: dreadkinFrames(kind)
        case .pyrekin: pyrekinFrames(kind)
        case .galekin: galekinFrames(kind)
        case .tidekin: tidekinFrames(kind)
        case .sludgekin: sludgekinFrames(kind)
        case .steelkin: steelkinFrames(kind)
        case .orbkin: orbkinFrames(kind)
        case .plushkin: plushkinFrames(kind)
        }
    }

    /// The strike is a simple mouth-open tell using the species'
    /// first attack pose. The projectile-forming pose is dropped —
    /// the actual projectile is shown in its own phase.
    private static func enhancedAttack(
        _ raw: [SpriteFrame]
    ) -> [SpriteFrame] {
        guard raw.count >= 2 else { return raw }
        let neutral = raw[0]
        let openMouth = raw[1]
        return [neutral, openMouth, openMouth, neutral]
    }
}

// Species projectiles live in SpriteCatalog+Projectiles.swift.

// MARK: - Default Animation Helpers

nonisolated extension SpriteCatalog {

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

    /// A weak, sagging loop derived from the idle frames — no per-species art,
    /// matching how sleep/happy are derived. Slow and drooping so a languishing
    /// pet reads as faint; paired on-screen with the flashing Call sign.
    static func weakAnimation(for species: PetSpecies) -> SpriteAnimation {
        let idle = frames(for: species, kind: .idle)
        let idle1 = idle.first ?? .empty
        let idle2 = idle.count > 1 ? idle[1] : idle1
        return SpriteAnimation(
            frames: [
                idle1.shiftedDown(1),
                idle1.shiftedDown(2),
                idle2.shiftedDown(1),
                idle1.shiftedDown(2)
            ],
            frameDuration: 0.7,
            loops: true
        )
    }

    /// Defeated slump: the pet sags low and heaves on the spot, head hung.
    /// Built from the first idle frame only — unlike `weakAnimation` it never
    /// cycles to the second idle, so species whose idle glances around don't
    /// look about mid-defeat.
    static func defeatAnimation(for species: PetSpecies) -> SpriteAnimation {
        let idle1 = frames(for: species, kind: .idle).first ?? .empty
        return SpriteAnimation(
            frames: [idle1.shiftedDown(1), idle1.shiftedDown(2)],
            frameDuration: 0.8,
            loops: true
        )
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
