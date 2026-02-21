import Testing
@testable import imon_Watch_App

@Suite("Weight")
struct WeightTests {

    @Test
    func `clamps to 5-99 range`() {
        #expect(Weight(3).grams == 5)
        #expect(Weight(100).grams == 99)
        #expect(Weight(50).grams == 50)
    }

    @Test
    func `overweight at 99G`() {
        #expect(Weight(99).isOverweight)
        #expect(!Weight(98).isOverweight)
    }
}
