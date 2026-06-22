import Foundation

nonisolated enum JSONPetStateStore {

    private static let key = "com.cliftonia.imon.petState"

    // MARK: - Live

    static func live(
        defaults: UserDefaults = .skykinShared
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

    // MARK: - Mock

    static func mock(
        save: @escaping @Sendable (PetState) throws -> Void = { _ in },
        load: @escaping @Sendable () throws -> PetState? = { nil },
        delete: @escaping @Sendable () throws -> Void = { }
    ) -> PetStateStore {
        PetStateStore(save: save, load: load, delete: delete)
    }
}
