import Foundation
import os

/// Builds the production `PetStateStore` witness: the pet serialised through
/// the versioned `PetStateDTO` into a single JSON blob in `UserDefaults` — a
/// save measured in hundreds of bytes, so a file store would add only failure
/// modes.
nonisolated enum JSONPetStateStore {

    /// The `UserDefaults` key holding the current JSON save.
    static let key = "com.cliftonia.imon.petState"
    /// The previous good save, kept so one torn or undecodable write cannot
    /// cost a months-old pet. Do not rename either key: both are on wrists.
    static let backupKey = "com.cliftonia.imon.petState.backup"

    // MARK: - Live

    /// Creates the store on `.standard` so persistence never depends on the
    /// App Group being provisioned. Only the complication hand-off needs the
    /// shared suite (`ComplicationStore`), and it degrades gracefully if that
    /// suite is missing.
    static func live(
        defaults: UserDefaults = .standard
    ) -> PetStateStore {
        // `UserDefaults` is thread-safe but not `Sendable`; safe to capture here.
        nonisolated(unsafe) let defaults = defaults
        return PetStateStore(
            save: { state in
                let data = try JSONEncoder().encode(PetStateDTO(from: state))
                if let previous = defaults.data(forKey: key) {
                    defaults.set(previous, forKey: backupKey)
                }
                defaults.set(data, forKey: key)
            },
            load: {
                guard let data = defaults.data(forKey: key) else {
                    return nil
                }
                do {
                    return PetState(from: try JSONDecoder().decode(PetStateDTO.self, from: data))
                } catch {
                    // The backup is one save behind; the engine's catch-up closes the gap.
                    guard let backup = defaults.data(forKey: backupKey) else { throw error }
                    Log.engine.error("Save undecodable; restoring backup: \(error, privacy: .public)")
                    return PetState(from: try JSONDecoder().decode(PetStateDTO.self, from: backup))
                }
            },
            delete: {
                defaults.removeObject(forKey: key)
                defaults.removeObject(forKey: backupKey)
            }
        )
    }
}
