import SwiftUI

/// Owns the `NavigationStack` path so non-View code (`AppPresenter`) can push
/// `AppRoute`s and pop back to the pet screen on phase changes.
@Observable
final class AppRouter {
    var path = NavigationPath()

    func navigate(to route: AppRoute) {
        path.append(route)
    }

    func popToRoot() {
        path = NavigationPath()
    }
}
