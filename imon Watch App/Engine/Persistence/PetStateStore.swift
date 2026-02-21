import Foundation

nonisolated struct PetStateStore: Sendable {
    let save: @Sendable (PetState) throws -> Void
    let load: @Sendable () throws -> PetState?
    let delete: @Sendable () throws -> Void
}
