import Testing
@testable import imon_Watch_App

@Suite("Airdramon Sprites")
struct AirdramonSpriteTests {

    // MARK: - Custom Animation Frame Counts

    @Test
    func `eat animation has four frames`() {
        let animation = SpriteCatalog.animation(
            for: .airdramon, kind: .eat
        )
        #expect(animation.frames.count == 4)
    }

    @Test
    func `happy animation has four frames`() {
        let animation = SpriteCatalog.animation(
            for: .airdramon, kind: .happy
        )
        #expect(animation.frames.count == 4)
    }

    @Test
    func `refuse animation has four frames`() {
        let animation = SpriteCatalog.animation(
            for: .airdramon, kind: .refuse
        )
        #expect(animation.frames.count == 4)
    }

    // MARK: - Custom Animations Are Not Default-Derived

    @Test
    func `eat does not use default shift-left pattern`() {
        let idle = SpriteCatalog.animation(
            for: .airdramon, kind: .idle
        )
        let eat = SpriteCatalog.animation(
            for: .airdramon, kind: .eat
        )
        // Default eat would be idle1.shiftedLeft(1)
        let defaultEat = idle.frames[0].shiftedLeft(1)
        #expect(eat.frames[0] != defaultEat)
    }

    @Test
    func `happy does not use default bounce pattern`() {
        let idle = SpriteCatalog.animation(
            for: .airdramon, kind: .idle
        )
        let happy = SpriteCatalog.animation(
            for: .airdramon, kind: .happy
        )
        // Default happy second frame would be shiftedUp(2)
        let defaultHappy2 = idle.frames[0].shiftedUp(2)
        #expect(happy.frames[1] != defaultHappy2)
    }

    @Test
    func `refuse keeps body anchored while head shifts`() {
        let idle = SpriteCatalog.animation(
            for: .airdramon, kind: .idle
        )
        let refuse = SpriteCatalog.animation(
            for: .airdramon, kind: .refuse
        )
        // Default refuse shifts the entire sprite;
        // custom refuse keeps wings (row 7) identical to idle
        let idleWingRow = idle.frames[0].rows[7]
        #expect(refuse.frames[0].rows[7] == idleWingRow)
        #expect(refuse.frames[1].rows[7] == idleWingRow)
    }

    // MARK: - Wing Tip Continuity

    @Test
    func `idle frames have body pixels in wing tip row`() {
        let idle = SpriteCatalog.animation(
            for: .airdramon, kind: .idle
        )
        for frame in idle.frames {
            let tipRow = frame.rows[9]
            // Body core at cols 4-9 should have pixels set
            let bodyCols: UInt16 = 0x0FC0 // ....######......
            #expect(tipRow & bodyCols == bodyCols)
        }
    }

    @Test
    func `eat last frame returns to idle`() {
        let idle = SpriteCatalog.animation(
            for: .airdramon, kind: .idle
        )
        let eat = SpriteCatalog.animation(
            for: .airdramon, kind: .eat
        )
        #expect(eat.frames[3] == idle.frames[0])
    }

    @Test
    func `refuse last frame returns to idle`() {
        let idle = SpriteCatalog.animation(
            for: .airdramon, kind: .idle
        )
        let refuse = SpriteCatalog.animation(
            for: .airdramon, kind: .refuse
        )
        #expect(refuse.frames[3] == idle.frames[0])
    }
}
