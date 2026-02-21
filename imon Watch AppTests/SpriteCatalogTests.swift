import Testing
@testable import imon_Watch_App

@Suite("SpriteCatalog")
struct SpriteCatalogTests {

    @Test
    func `refuse animation has four frames`() {
        let animation = SpriteCatalog.animation(
            for: .agumon,
            kind: .refuse
        )
        #expect(animation.frames.count == 4)
    }

    @Test
    func `refuse animation does not loop`() {
        let animation = SpriteCatalog.animation(
            for: .agumon,
            kind: .refuse
        )
        #expect(!animation.loops)
    }

    @Test
    func `refuse animation has correct frame duration`() {
        let animation = SpriteCatalog.animation(
            for: .agumon,
            kind: .refuse
        )
        #expect(animation.frameDuration == 0.15)
    }

    @Test
    func `refuse animation derives from idle`() {
        let idle = SpriteCatalog.animation(
            for: .agumon,
            kind: .idle
        )
        let refuse = SpriteCatalog.animation(
            for: .agumon,
            kind: .refuse
        )
        let base = idle.frames[0]
        #expect(refuse.frames[0] == base.shiftedLeft(1))
        #expect(refuse.frames[1] == base.shiftedRight(1))
        #expect(refuse.frames[2] == base.shiftedLeft(1))
        #expect(refuse.frames[3] == base)
    }
}
