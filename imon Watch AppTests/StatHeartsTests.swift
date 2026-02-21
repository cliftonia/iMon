import Testing
@testable import imon_Watch_App

@Suite("StatHearts")
struct StatHeartsTests {

    @Test
    func `clamps to 0-4 range`() {
        #expect(StatHearts(-1).value == 0)
        #expect(StatHearts(5).value == 4)
        #expect(StatHearts(3).value == 3)
    }

    @Test
    func `increment and decrement respect bounds`() {
        var hearts = StatHearts(3)
        hearts.increment()
        #expect(hearts.value == 4)
        hearts.increment()
        #expect(hearts.value == 4)

        var empty = StatHearts(0)
        empty.decrement()
        #expect(empty.value == 0)
    }
}
