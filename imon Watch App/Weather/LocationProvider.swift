import CoreLocation
import Foundation

/// One-shot current-location lookup. Closure-based so it can be mocked.
nonisolated struct LocationProvider: Sendable {
    let currentLocation: @Sendable () async throws -> CLLocation
}

nonisolated extension LocationProvider {

    static func live(timeout: Duration = .seconds(10)) -> LocationProvider {
        LocationProvider {
            await LocationAuthorizer.shared.requestIfNeeded()
            return try await firstFix(timeout: timeout)
        }
    }

    /// First good fix from a live updates session, or throws on timeout/denial.
    private static func firstFix(timeout: Duration) async throws -> CLLocation {
        try await withThrowingTaskGroup(of: CLLocation?.self) { group in
            group.addTask {
                for try await update in CLLocationUpdate.liveUpdates() {
                    if update.authorizationDenied { return nil }
                    if let location = update.location { return location }
                }
                return nil
            }
            group.addTask {
                try? await Task.sleep(for: timeout)
                return nil
            }
            defer { group.cancelAll() }
            let result = (try await group.next()) ?? nil
            guard let location = result else {
                throw WeatherError.locationUnavailable
            }
            return location
        }
    }
}

/// Owns a long-lived CLLocationManager so the authorization prompt isn't
/// dismissed by the manager deallocating mid-request.
@MainActor
private final class LocationAuthorizer {
    static let shared = LocationAuthorizer()
    private let manager = CLLocationManager()

    func requestIfNeeded() {
        if manager.authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        }
    }
}
