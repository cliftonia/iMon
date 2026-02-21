import Foundation

nonisolated struct ErrorViewConfiguration: Hashable, Sendable {
    let title: String
    let message: String
    let retryActionLabel: String
}
