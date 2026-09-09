import Foundation

/// The persistence boundary as a witness. Three closures a test can stub
/// individually, with the production wiring supplied by
/// `JSONPetStateStore.live`. `load` returns `nil` when no save exists;
/// throwing is reserved for a save that exists but cannot be decoded.
nonisolated struct PetStateStore: Sendable {
    /// Persists the pet's state.
    let save: @Sendable (PetState) throws -> Void
    /// Returns the saved pet state, or nil when no save exists. Throws only
    /// when a save exists but cannot be decoded.
    let load: @Sendable () throws -> PetState?
    /// Removes the saved pet state.
    let delete: @Sendable () throws -> Void
}
