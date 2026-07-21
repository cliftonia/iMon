import Foundation

/// Immutable inputs for `LCDDisplay` — one value instead of a dozen view
/// parameters. Built per render from the resolved `LCDScene` plus the sprites.
nonisolated struct LCDDisplayConfiguration: Hashable, Sendable {
    let leftSprite: SpriteFrame
    let rightSprite: SpriteFrame?
    let poopCount: Int
    let stinkPhase: Int
    let lightsOn: Bool
    let leftSpriteOffsetX: Int
    let leftSpriteOffsetY: Int
    let rightSpriteOffsetY: Int
    let weatherCondition: WeatherIconCondition?
    let moonPhase: MoonPhase
    let dayPhase: DayPhase
    let stormFlash: Bool
    /// The evolution strobe — a full-screen white-out flash with no VS text.
    let evolveFlash: Bool
    /// Blinks a Call sign (the toy's attention alert) while the pet languishes.
    let showCallSign: Bool

    init(
        leftSprite: SpriteFrame,
        rightSprite: SpriteFrame? = nil,
        poopCount: Int = 0,
        stinkPhase: Int = 0,
        lightsOn: Bool = true,
        leftSpriteOffsetX: Int = 8,
        leftSpriteOffsetY: Int = 4,
        rightSpriteOffsetY: Int = 4,
        weatherCondition: WeatherIconCondition? = nil,
        moonPhase: MoonPhase = .full,
        dayPhase: DayPhase = .day,
        stormFlash: Bool = false,
        evolveFlash: Bool = false,
        showCallSign: Bool = false
    ) {
        self.leftSprite = leftSprite
        self.rightSprite = rightSprite
        self.poopCount = poopCount
        self.stinkPhase = stinkPhase
        self.lightsOn = lightsOn
        self.leftSpriteOffsetX = leftSpriteOffsetX
        self.leftSpriteOffsetY = leftSpriteOffsetY
        self.rightSpriteOffsetY = rightSpriteOffsetY
        self.weatherCondition = weatherCondition
        self.moonPhase = moonPhase
        self.dayPhase = dayPhase
        self.stormFlash = stormFlash
        self.evolveFlash = evolveFlash
        self.showCallSign = showCallSign
    }
}
