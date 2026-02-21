import Testing
@testable import imon_Watch_App

@Suite("CleanAction")
struct CleanActionTests {

    @Test
    func `clean removes all poop`() {
        var state = makeTestState()
        state.poopCount = 3
        state = CleanAction.apply(to: state)
        #expect(state.poopCount == 0)
    }

    @Test
    func `cannot clean when no poop`() {
        var state = makeTestState()
        state.poopCount = 0
        #expect(!CleanAction.canClean(state))
    }
}
