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
    private let throttle = ThrottledFetch()

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

    /// Night derived from the reading's daylight flag, but only while the reading
    /// is still fresh. A stale reading (e.g. last night's, on reopening the next
    /// day) returns nil so day/night falls back to the clock instead of showing
    /// the old night until a fetch completes.
    func nightSignal(now: Date = .now) -> Bool? {
        guard let snapshot, let lastSuccess = throttle.lastSuccess,
              now.timeIntervalSince(lastSuccess) < TimeConstants.weatherCacheInterval
        else {
            return nil
        }
        return !snapshot.isDaylight
    }

    /// Kicks off a refresh unless one is in flight or the last fetch is still
    /// within the cache window. Returns the spawned task (nil if skipped).
    @discardableResult
    func refreshIfStale(now: Date = .now) -> Task<Void, Never>? {
        throttle.startIfStale(
            now: now,
            isFresh: { now.timeIntervalSince($0) < TimeConstants.weatherCacheInterval }
        ,
            run: { [weak self] in
                await self?.refresh(now: now)
            }
        )
    }

    /// Fetches and stores a snapshot, leaving the existing value on failure.
    /// Failures still count toward the cache window (so a missing
    /// authorization doesn't spin a fetch on every wrist raise) but never
    /// refresh the reading's age — the surviving snapshot ages out honestly.
    func refresh(now: Date = .now) async {
        do {
            snapshot = try await provider.fetchCurrent()
            throttle.record(now: now, success: true)
        } catch {
            Log.weather.error("Weather fetch failed: \(error, privacy: .public)")
            throttle.record(now: now, success: false)
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

}
