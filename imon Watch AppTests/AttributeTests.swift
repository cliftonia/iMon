import Testing
@testable import imon_Watch_App

@Suite("Attribute")
struct AttributeTests {

    @Test
    func `advantage triangle vaccine beats virus beats data`() {
        #expect(Attribute.vaccine.hasAdvantageOver(.virus))
        #expect(Attribute.virus.hasAdvantageOver(.data))
        #expect(Attribute.data.hasAdvantageOver(.vaccine))
        #expect(!Attribute.vaccine.hasAdvantageOver(.data))
        #expect(!Attribute.virus.hasAdvantageOver(.vaccine))
    }
}
