import Foundation
import HealthKit

nonisolated struct StepCountProvider: Sendable {
    let fetchTodaySteps: @Sendable () async throws -> Int
}

extension StepCountProvider {
    static func live() -> StepCountProvider {
        let store = HKHealthStore()
        return StepCountProvider(
            fetchTodaySteps: {
                let stepType = HKQuantityType(.stepCount)
                let calendar = Calendar.current
                let startOfDay = calendar.startOfDay(for: .now)
                let predicate = HKQuery.predicateForSamples(
                    withStart: startOfDay,
                    end: .now,
                    options: .strictStartDate
                )
                let samplePredicate = HKSamplePredicate.quantitySample(
                    type: stepType,
                    predicate: predicate
                )
                let descriptor = HKStatisticsQueryDescriptor(
                    predicate: samplePredicate,
                    options: .cumulativeSum
                )
                let result = try await descriptor.result(for: store)
                let sum = result?.sumQuantity()?.doubleValue(for: .count()) ?? 0
                return Int(sum)
            }
        )
    }

    static func mock(steps: Int = 0) -> StepCountProvider {
        StepCountProvider(fetchTodaySteps: { steps })
    }
}
