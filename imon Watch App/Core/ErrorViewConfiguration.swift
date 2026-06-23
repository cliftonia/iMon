import Foundation

// AUDIT 2026-06-24: never constructed anywhere. Kept as the project's standard
// error-presentation shape for when a screen needs a retryable error. Keep or remove.
nonisolated struct ErrorViewConfiguration: Hashable, Sendable {
    let title: String
    let message: String
    let retryActionLabel: String
}
