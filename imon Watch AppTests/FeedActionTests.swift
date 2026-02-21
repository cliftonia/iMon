import Testing
@testable import imon_Watch_App

@Suite("FeedAction")
struct FeedActionTests {

    @Test
    func `meat increases hunger by 1 and weight by 1G`() {
        var state = makeTestState(hunger: 2, weight: 20)
        state = FeedAction.apply(to: state, food: .meat)
        #expect(state.hungerHearts.value == 3)
        #expect(state.weight.grams == 21)
    }

    @Test
    func `vitamin increases strength by 1 and weight by 2G`() {
        var state = makeTestState(strength: 2, weight: 20)
        state = FeedAction.apply(to: state, food: .vitamin)
        #expect(state.strengthHearts.value == 3)
        #expect(state.weight.grams == 22)
    }

    @Test
    func `cannot feed while sleeping`() {
        var state = makeTestState()
        state.isSleeping = true
        #expect(!FeedAction.canFeed(state))
    }

    @Test
    func `cannot feed when dead`() {
        var state = makeTestState()
        state.isDead = true
        #expect(!FeedAction.canFeed(state))
    }
}
