import Foundation

nonisolated enum JSONPetStateStore {

    private static let key = "com.cliftonia.imon.petState"

    // MARK: - Live

    // Pet state stays in `.standard` so persistence never depends on the App
    // Group being provisioned. Only the complication hand-off needs the shared
    // suite (`ComplicationStore`), and it degrades gracefully if it's missing.
    static func live(
        defaults: UserDefaults = .standard
    ) -> PetStateStore {
        // `UserDefaults` is documented thread-safe but not `Sendable`; capturing
        // it in the witness's `@Sendable` closures is safe.
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
