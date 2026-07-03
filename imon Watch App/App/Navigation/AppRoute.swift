import Foundation

enum AppRoute: Hashable {
    // AUDIT 2026-06-24: only `.stats` is ever navigated to (lifecycle screens use
    // AppPresenter.phase, not the NavigationStack). `.pet`/`.hatch`/`.death` are
    // unused route cases — keep for future push-navigation or remove.
    case pet
    case stats
    case settings
    case hatch
    case death
}
