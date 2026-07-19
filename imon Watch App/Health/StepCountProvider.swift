import Foundation
import HealthKit

/// Fetches today's step total, injected as a protocol witness so everything
/// built on steps can be tested without HealthKit. "Today" is anchored to the
/// local midnight — a count never carries across days.
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
                // .cumulativeSum already dedupes watch + iPhone sources — no source filter.
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

    /// Requests read access to step count. Safe to call at every launch;
    /// HealthKit only prompts once. No-op if HealthKit is unavailable.
    static func requestAuthorization() async {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        let store = HKHealthStore()
        try? await store.requestAuthorization(
            toShare: [],
            read: [HKQuantityType(.stepCount)]
        )
    }
}
