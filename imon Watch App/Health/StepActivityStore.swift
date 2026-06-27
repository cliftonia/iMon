import Foundation
import os

/// Holds today's step count and refreshes it on demand, throttled to the cache
/// window. Leaves `todaySteps` nil when unavailable, so the engine falls back to
/// baseline (activity-neutral) rates. Mirrors `WeatherStore`.
@Observable
final class StepActivityStore {

    private(set) var todaySteps: Int?

    private let provider: StepCountProvider
    private var lastFetch: Date?
    private var fetchTask: Task<Void, Never>?

    init(provider: StepCountProvider = .live()) {
        self.provider = provider
    }

    /// Kicks off a refresh unless one is in flight or still within the cache
    /// window. Returns the spawned task (nil if skipped).
    @discardableResult
    func refreshIfStale(now: Date = .now) -> Task<Void, Never>? {
        guard shouldRefresh(now: now) else { return nil }
        let task = Task { [weak self] in
            guard let self else { return }
            await self.refresh(now: now)
        }
        fetchTask = task
        return task
    }

    /// Fetches and stores today's steps, leaving the existing value on failure.
    func refresh(now: Date = .now) async {
        defer { fetchTask = nil }
        do {
            todaySteps = try await provider.fetchTodaySteps()
            lastFetch = now
        } catch {
            Log.health.error("Step fetch failed: \(error, privacy: .public)")
            // Apply the cache window to failures too, so a missing authorization
            // doesn't spin a fetch on every wrist raise.
            lastFetch = now
        }
    }

    static func makeDefault() -> StepActivityStore {
        StepActivityStore()
    }

    private func shouldRefresh(now: Date) -> Bool {
        guard fetchTask == nil else { return false }
        if let last = lastFetch,
           now.timeIntervalSince(last) < TimeConstants.stepCacheInterval {
            return false
        }
        return true
    }
}
