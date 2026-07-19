import Foundation

/// Builds the production `PetStateStore`: the pet serialised through the
/// versioned `PetStateDTO` into a single JSON blob in `UserDefaults` — a save
/// measured in hundreds of bytes, so a file store would add only failure modes.
nonisolated enum JSONPetStateStore {

    private static let key = "com.cliftonia.imon.petState"

    // MARK: - Live

    /// Pet state stays in `.standard` so persistence never depends on the App
    /// Group being provisioned. Only the complication hand-off needs the
    /// shared suite (`ComplicationStore`), and it degrades gracefully if
    /// that suite is missing.
    static func live(
        defaults: UserDefaults = .standard
    ) -> PetStateStore {
        // `UserDefaults` is thread-safe but not `Sendable`; safe to capture here.
        nonisolated(unsafe) let defaults = defaults
        return PetStateStore(
            save: { state in
                let data = try JSONEncoder().encode(PetStateDTO(from: state))
                defaults.set(data, forKey: key)
            },
            load: {
                guard let data = defaults.data(forKey: key) else {
                    return nil
                }
                let dto = try JSONDecoder().decode(PetStateDTO.self, from: data)
                return PetState(from: dto)
            },
            delete: {
                defaults.removeObject(forKey: key)
            }
        )
    }
}
