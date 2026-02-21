import Foundation

nonisolated enum JSONPetStateStore {

    private static let key = "com.cliftonia.imon.petState"

    // MARK: - Live

    static func live(
        defaults: UserDefaults = .standard
    ) -> PetStateStore {
        PetStateStore(
            save: { state in
                let data = try JSONEncoder().encode(state)
                defaults.set(data, forKey: key)
            },
            load: {
                guard let data = defaults.data(forKey: key) else {
                    return nil
                }
                return try JSONDecoder().decode(PetState.self, from: data)
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
