import Testing
@testable import imon_Watch_App

@Suite("TrainAction")
struct TrainActionTests {

    @Test
    func `generated number is 1-9 and not 5`() {
        for _ in 0..<100 {
            let num = TrainAction.generateNumber()
            #expect(num >= 1 && num <= 9)
            #expect(num != 5)
        }
    }

    @Test
    func `high guess wins when number is greater than 5`() {
        let result = TrainAction.evaluateRound(
            number: 7, guess: .high
        )
        #expect(result.won)
    }

    @Test
    func `low guess wins when number is less than 5`() {
        let result = TrainAction.evaluateRound(
            number: 3, guess: .low
        )
        #expect(result.won)
    }

    @Test
    func `wrong guess loses`() {
        let result = TrainAction.evaluateRound(
            number: 8, guess: .low
        )
        #expect(!result.won)
    }

    @Test
    func `winning training increases strength and decreases weight`() {
        var state = makeTestState(strength: 2, weight: 30)
        state = TrainAction.applyResult(
            to: state, won: true
        )
        #expect(state.strengthHearts.value == 3)
        #expect(state.weight.grams == 28)
        #expect(state.trainingCount == 1)
    }
}
