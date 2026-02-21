import Testing
import Foundation
@testable import imon_Watch_App

// MARK: - Test Helpers

func makeTestState(
    species: DigimonSpecies = .agumon,
    hunger: Int = 4,
    strength: Int = 4,
    weight: Int = 20,
    at date: Date = .now
) -> PetState {
    var state = PetState.hatched(at: date)
    state.species = species
    state.hungerHearts = StatHearts(hunger)
    state.strengthHearts = StatHearts(strength)
    state.weight = Weight(weight)
    return state
}

// MARK: - StatHearts Tests

@Suite("StatHearts")
struct StatHeartsTests {
    @Test("Clamps to 0-4 range")
    func clamping() {
        #expect(StatHearts(-1).value == 0)
        #expect(StatHearts(5).value == 4)
        #expect(StatHearts(3).value == 3)
    }

    @Test("Increment and decrement respect bounds")
    func incrementDecrement() {
        var hearts = StatHearts(3)
        hearts.increment()
        #expect(hearts.value == 4)
        hearts.increment()
        #expect(hearts.value == 4) // capped at 4

        var empty = StatHearts(0)
        empty.decrement()
        #expect(empty.value == 0) // floored at 0
    }
}

// MARK: - Weight Tests

@Suite("Weight")
struct WeightTests {
    @Test("Clamps to 5-99 range")
    func clamping() {
        #expect(Weight(3).grams == 5)
        #expect(Weight(100).grams == 99)
        #expect(Weight(50).grams == 50)
    }

    @Test("Overweight at 99G")
    func overweight() {
        #expect(Weight(99).isOverweight)
        #expect(!Weight(98).isOverweight)
    }
}

// MARK: - FeedAction Tests

@Suite("FeedAction")
struct FeedActionTests {
    @Test("Meat increases hunger by 1 and weight by 1G")
    func feedMeat() {
        var state = makeTestState(hunger: 2, weight: 20)
        state = FeedAction.apply(to: state, food: .meat)
        #expect(state.hungerHearts.value == 3)
        #expect(state.weight.grams == 21)
    }

    @Test("Vitamin increases strength by 1 and weight by 2G")
    func feedVitamin() {
        var state = makeTestState(strength: 2, weight: 20)
        state = FeedAction.apply(to: state, food: .vitamin)
        #expect(state.strengthHearts.value == 3)
        #expect(state.weight.grams == 22)
    }

    @Test("Cannot feed while sleeping")
    func cannotFeedWhileSleeping() {
        var state = makeTestState()
        state.isSleeping = true
        #expect(!FeedAction.canFeed(state))
    }

    @Test("Cannot feed when dead")
    func cannotFeedWhenDead() {
        var state = makeTestState()
        state.isDead = true
        #expect(!FeedAction.canFeed(state))
    }
}

// MARK: - HungerSimulator Tests

@Suite("HungerSimulator")
struct HungerSimulatorTests {
    @Test("Depletes one heart per interval")
    func depletion() {
        let start = Date.now
        var state = makeTestState(hunger: 4, at: start)
        state.lastHungerDecayAt = start

        // Advance 70 minutes (1 interval)
        let later = start.addingTimeInterval(TimeConstants.hungerDepletionInterval)
        state = HungerSimulator.apply(to: state, at: later)
        #expect(state.hungerHearts.value == 3)
    }

    @Test("Multiple intervals deplete multiple hearts")
    func multipleIntervals() {
        let start = Date.now
        var state = makeTestState(hunger: 4, at: start)
        state.lastHungerDecayAt = start

        // Advance 3 intervals
        let later = start.addingTimeInterval(TimeConstants.hungerDepletionInterval * 3)
        state = HungerSimulator.apply(to: state, at: later)
        #expect(state.hungerHearts.value == 1)
    }

    @Test("Does not deplete while sleeping")
    func noDepletionWhileSleeping() {
        let start = Date.now
        var state = makeTestState(hunger: 4, at: start)
        state.isSleeping = true
        state.lastHungerDecayAt = start

        let later = start.addingTimeInterval(TimeConstants.hungerDepletionInterval * 5)
        state = HungerSimulator.apply(to: state, at: later)
        #expect(state.hungerHearts.value == 4)
    }
}

// MARK: - DeathEvaluator Tests

@Suite("DeathEvaluator")
struct DeathEvaluatorTests {
    @Test("Dies from too many care mistakes")
    func careMistakeDeath() {
        var state = makeTestState()
        state.careMistakes = 20
        let cause = DeathEvaluator.evaluate(state, at: .now)
        #expect(cause == .careMistakes)
    }

    @Test("Dies from too many injuries")
    func injuryDeath() {
        var state = makeTestState()
        state.injuryCount = 20
        let cause = DeathEvaluator.evaluate(state, at: .now)
        #expect(cause == .injuries)
    }

    @Test("Dies from untreated injury after 6 hours")
    func untreatedInjuryDeath() {
        let start = Date.now
        var state = makeTestState()
        state.isInjured = true
        state.injuredAt = start

        let later = start.addingTimeInterval(TimeConstants.untreatedInjuryDeathTime + 1)
        let cause = DeathEvaluator.evaluate(state, at: later)
        #expect(cause == .untreatedInjury)
    }

    @Test("Survives with acceptable stats")
    func survives() {
        let state = makeTestState()
        let cause = DeathEvaluator.evaluate(state, at: .now)
        #expect(cause == nil)
    }
}

// MARK: - EvolutionEngine Tests

@Suite("EvolutionEngine")
struct EvolutionEngineTests {
    @Test("Botamon evolves to Koromon after 1 hour")
    func botamonToKoromon() {
        let start = Date.now
        var state = makeTestState(species: .botamon, at: start)
        state.evolvedAt = start

        let later = start.addingTimeInterval(TimeConstants.babyEvolutionTime + 1)
        let target = EvolutionEngine.checkEvolution(for: state, at: later)
        #expect(target == .koromon)
    }

    @Test("Koromon evolves to Agumon with 0-1 care mistakes")
    func koromonToAgumon() {
        let start = Date.now
        var state = makeTestState(species: .koromon, at: start)
        state.evolvedAt = start
        state.careMistakes = 0

        let later = start.addingTimeInterval(TimeConstants.rookieEvolutionTime + 1)
        let target = EvolutionEngine.checkEvolution(for: state, at: later)
        #expect(target == .agumon)
    }

    @Test("Koromon evolves to Betamon with 2+ care mistakes")
    func koromonToBetamon() {
        let start = Date.now
        var state = makeTestState(species: .koromon, at: start)
        state.evolvedAt = start
        state.careMistakes = 3

        let later = start.addingTimeInterval(TimeConstants.rookieEvolutionTime + 1)
        let target = EvolutionEngine.checkEvolution(for: state, at: later)
        #expect(target == .betamon)
    }

    @Test("Ultimate stage cannot evolve further")
    func ultimateNoEvolution() {
        let state = makeTestState(species: .metalGreymon)
        let target = EvolutionEngine.checkEvolution(for: state, at: .now)
        #expect(target == nil)
    }
}

// MARK: - BattleEngine Tests

@Suite("BattleEngine")
struct BattleEngineTests {
    @Test("Battle returns a valid result")
    func battleResult() {
        let state = makeTestState(species: .greymon, strength: 4, weight: 30)
        let opponent = BattleOpponent.generate(matching: state)
        let result = BattleEngine.battle(petState: state, opponent: opponent)
        #expect([BattleResult.win, .lose, .draw].contains(result))
    }

    @Test("Apply result increments win count")
    func applyWin() {
        var state = makeTestState()
        state.battleWins = 0
        state = BattleEngine.applyResult(.win, to: state)
        #expect(state.battleWins == 1)
    }

    @Test("Apply result increments loss count")
    func applyLoss() {
        var state = makeTestState()
        state.battleLosses = 0
        state = BattleEngine.applyResult(.lose, to: state)
        #expect(state.battleLosses == 1)
    }
}

// MARK: - TrainAction Tests

@Suite("TrainAction")
struct TrainActionTests {
    @Test("Generated number is 1-9 and not 5")
    func generateNumber() {
        for _ in 0..<100 {
            let num = TrainAction.generateNumber()
            #expect(num >= 1 && num <= 9)
            #expect(num != 5)
        }
    }

    @Test("High guess wins when number > 5")
    func highGuessWins() {
        let result = TrainAction.evaluateRound(number: 7, guess: .high)
        #expect(result.won)
    }

    @Test("Low guess wins when number < 5")
    func lowGuessWins() {
        let result = TrainAction.evaluateRound(number: 3, guess: .low)
        #expect(result.won)
    }

    @Test("Wrong guess loses")
    func wrongGuess() {
        let result = TrainAction.evaluateRound(number: 8, guess: .low)
        #expect(!result.won)
    }

    @Test("Winning training increases strength and decreases weight")
    func winningTraining() {
        var state = makeTestState(strength: 2, weight: 30)
        state = TrainAction.applyResult(to: state, won: true)
        #expect(state.strengthHearts.value == 3)
        #expect(state.weight.grams == 28)
        #expect(state.trainingCount == 1)
    }
}

// MARK: - GameEngine Tests

@Suite("GameEngine")
struct GameEngineTests {
    @Test("Advance updates age in days")
    func ageUpdate() {
        let start = Date.now.addingTimeInterval(-86400 * 3) // 3 days ago
        var state = makeTestState(at: start)
        state.bornAt = start

        state = GameEngine.advance(state, to: .now)
        #expect(state.age >= 3)
    }

    @Test("Dead pet is not advanced")
    func deadNotAdvanced() {
        var state = makeTestState(hunger: 4)
        state.isDead = true
        let original = state
        state = GameEngine.advance(state, to: .now)
        #expect(state.hungerHearts.value == original.hungerHearts.value)
    }

    @Test("Egg is not advanced")
    func eggNotAdvanced() {
        var state = PetState.newEgg()
        let original = state
        state = GameEngine.advance(state, to: .now)
        #expect(state.isEgg == original.isEgg)
    }
}

// MARK: - CleanAction Tests

@Suite("CleanAction")
struct CleanActionTests {
    @Test("Clean removes all poop")
    func cleanRemovesPoop() {
        var state = makeTestState()
        state.poopCount = 3
        state = CleanAction.apply(to: state)
        #expect(state.poopCount == 0)
    }

    @Test("Cannot clean when no poop")
    func cannotCleanNoPoop() {
        var state = makeTestState()
        state.poopCount = 0
        #expect(!CleanAction.canClean(state))
    }
}

// MARK: - StepBonusCalculator Tests

@Suite("StepBonusCalculator")
struct StepBonusCalculatorTests {
    @Test("1000 steps = 1 bonus meal", arguments: [
        (0, 0), (999, 0), (1000, 1), (2500, 2), (5000, 5)
    ])
    func bonusMeals(steps: Int, expected: Int) {
        #expect(StepBonusCalculator.bonusMeals(from: steps) == expected)
    }
}

// MARK: - Attribute Tests

@Suite("Attribute")
struct AttributeTests {
    @Test("Advantage triangle: vaccine > virus > data > vaccine")
    func advantageTriangle() {
        #expect(Attribute.vaccine.hasAdvantageOver(.virus))
        #expect(Attribute.virus.hasAdvantageOver(.data))
        #expect(Attribute.data.hasAdvantageOver(.vaccine))
        #expect(!Attribute.vaccine.hasAdvantageOver(.data))
        #expect(!Attribute.virus.hasAdvantageOver(.vaccine))
    }
}
