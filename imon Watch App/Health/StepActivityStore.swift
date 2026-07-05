import Foundation
import os

/// Holds today's step count and refreshes it on demand, throttled to the cache
/// window. Leaves `todaySteps` nil when unavailable, so the engine falls back to
/// baseline (activity-neutral) rates. Mirrors `WeatherStore`.
@Observable
final class StepActivityStore {

    /// Today's step reading, or nil if the last successful fetch belongs to an
    /// earlier calendar day. A count cached before midnight must never be served
    /// as the new day's — the engine's day-rollover would credit yesterday's
    /// whole total again and poison the new day's baseline and lazy-day check.
    var todaySteps: Int? {
        guard let lastSuccess,
              Calendar.current.isDate(lastSuccess, inSameDayAs: .now)
        else { return nil }
        return fetchedSteps
    }

    private var fetchedSteps: Int?
    private let provider: StepCountProvider
    /// Last attempt, success or failure — throttles refreshes.
    private var lastFetch: Date?
    /// Last successful fetch — dates the reading's calendar day.
    private var lastSuccess: Date?
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
            fetchedSteps = try await provider.fetchTodaySteps()
            lastFetch = now
            lastSuccess = now
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
        // The cache only holds within a calendar day — crossing midnight
        // refetches immediately so the new day starts from a real reading.
        if let last = lastFetch,
           now.timeIntervalSince(last) < TimeConstants.stepCacheInterval,
           Calendar.current.isDate(last, inSameDayAs: now) {
            return false
        }
        return true
    }
}
