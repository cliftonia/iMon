import Foundation
import os

/// Holds the current weather snapshot and refreshes it on demand, throttled to
/// the cache window. Leaves `snapshot` nil when weather is unavailable, so the
/// UI can simply hide the overlay.
@Observable
final class WeatherStore {

    private(set) var snapshot: WeatherSnapshot?

    private let provider: WeatherProvider
    private let fallback: WeatherSnapshot?
    private var lastFetch: Date?
    private var fetchTask: Task<Void, Never>?

    /// The snapshot the UI should render. In Release this is just `snapshot`;
    /// in DEBUG a preview override can force a condition to polish its effect.
    var displaySnapshot: WeatherSnapshot? {
        #if DEBUG
        if let debugCondition {
            let base = snapshot ?? .sample
            return WeatherSnapshot(
                temperature: base.temperature,
                condition: debugCondition,
                isDaylight: base.isDaylight,
                humidity: base.humidity
            )
        }
        #endif
        return snapshot ?? fallback
    }

    #if DEBUG
    /// Preview override for cycling through weather effects on-device.
    private(set) var debugCondition: WeatherIconCondition?

    /// Advance the preview: real → clear → cloudy → … → fog → wind → real.
    func cycleDebugCondition() {
        let all = WeatherIconCondition.allCases
        switch debugCondition {
        case .none:
            debugCondition = all.first
        case .some(let current):
            let next = (all.firstIndex(of: current) ?? -1) + 1
            debugCondition = next < all.count ? all[next] : nil
        }
    }
    #endif

    /// - Parameter fallback: shown only when a fetch fails and no real reading
    ///   exists yet. Left nil in Release so the overlay simply hides.
    init(provider: WeatherProvider = .live(), fallback: WeatherSnapshot? = nil) {
        self.provider = provider
        self.fallback = fallback
    }

    /// Kicks off a refresh unless one is in flight or the last fetch is still
    /// within the cache window. Returns the spawned task (nil if skipped).
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

    /// Fetches and stores a snapshot, leaving the existing value on failure.
    func refresh(now: Date = .now) async {
        defer { fetchTask = nil }
        do {
            snapshot = try await provider.fetchCurrent()
            lastFetch = now
        } catch {
            Log.weather.error("Weather fetch failed: \(error, privacy: .public)")
            // Leave `snapshot` nil so day/night uses the time window, not the
            // DEBUG sample. The overlay still shows the sample via displaySnapshot.
        }
    }

    /// Live store with a DEBUG-only placeholder so the overlay is visible before
    /// the WeatherKit capability is provisioned. Release shows real data only.
    static func makeDefault() -> WeatherStore {
        #if DEBUG
        return WeatherStore(provider: .live(), fallback: .sample)
        #else
        return WeatherStore(provider: .live())
        #endif
    }

    private func shouldRefresh(now: Date) -> Bool {
        guard fetchTask == nil else { return false }
        if let last = lastFetch,
           now.timeIntervalSince(last) < TimeConstants.weatherCacheInterval {
            return false
        }
        return true
    }
}
