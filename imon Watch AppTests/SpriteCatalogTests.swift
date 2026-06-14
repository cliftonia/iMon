import Testing
@testable import imon_Watch_App

@Suite("SpriteCatalog")
struct SpriteCatalogTests {

    @Test
    func `refuse animation has four frames`() {
        let animation = SpriteCatalog.animation(
            for: .emberkin,
            kind: .refuse
        )
        #expect(animation.frames.count == 4)
    }

    @Test
    func `refuse animation does not loop`() {
        let animation = SpriteCatalog.animation(
            for: .emberkin,
            kind: .refuse
        )
        #expect(!animation.loops)
    }

    @Test
    func `refuse animation has correct frame duration`() {
        let animation = SpriteCatalog.animation(
            for: .emberkin,
            kind: .refuse
        )
        #expect(animation.frameDuration == 0.15)
    }
}
