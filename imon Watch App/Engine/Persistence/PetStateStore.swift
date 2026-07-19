import Foundation

/// The persistence boundary as a protocol witness: three closures a test can
/// stub individually, with the production wiring supplied by
/// `JSONPetStateStore.live`. `load` returns `nil` when no save exists;
/// throwing is reserved for a save that exists but cannot be decoded.
nonisolated struct PetStateStore: Sendable {
    let save: @Sendable (PetState) throws -> Void
    let load: @Sendable () throws -> PetState?
    let delete: @Sendable () throws -> Void
}
