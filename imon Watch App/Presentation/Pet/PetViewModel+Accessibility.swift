import Foundation

// MARK: - VoiceOver

extension PetViewModel {

    /// One spoken sentence for the whole home screen — the LCD itself is a
    /// Canvas, so this is the only way the pet's condition reaches VoiceOver.
    var accessibilityDescription: String {
        guard let status else { return "Virtual pet" }
        var parts = [
            "\(status.species.displayName), \(status.stage.displayName)",
            "hunger \(status.hungerHearts.value) of \(status.species.maxHunger)",
            "strength \(status.strengthHearts.value) of \(status.species.maxStrength)"
        ]
        if status.isSleeping { parts.append("sleeping") }
        if status.poopCount > 0 {
            parts.append(status.poopCount == 1 ? "1 mess to clean" : "\(status.poopCount) messes to clean")
        }
        if status.isInjured { parts.append("injured") }
        if status.isLanguishing { parts.append("needs care") }
        parts.append("menu: \(menuSelection.accessibilityName)")
        return parts.joined(separator: ", ")
    }
}

extension PetViewModel.MenuAction {

    var accessibilityName: String {
        switch self {
        case .stats: "stats"
        case .feed: "feed"
        case .train: "train"
        case .battle: "battle"
        case .clean: "clean"
        case .lights: "lights"
        case .heal: "heal"
        case .settings: "settings"
        }
    }
}
