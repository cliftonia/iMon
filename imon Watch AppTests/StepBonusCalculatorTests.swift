import Testing
@testable import imon_Watch_App

@Suite("StepBonusCalculator")
struct StepBonusCalculatorTests {

    @Test(arguments: [
        (0, 0), (999, 0), (1000, 1), (2500, 2), (5000, 5)
    ])
    func `bonus meals from steps`(
        steps: Int,
        expected: Int
    ) {
        #expect(
            StepBonusCalculator.bonusMeals(from: steps)
                == expected
        )
    }
}
