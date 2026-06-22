import Foundation

/// App-side builder: turns a `PetState` into a `ComplicationEntry`, baking the
/// display values and the current sprite rows. Lives only in the app target
/// (it touches `PetStatus` and `SpriteCatalog`), keeping `ComplicationEntry`
/// itself engine-free for sharing with the widget.
nonisolated extension ComplicationEntry {

    init(date: Date, state: PetState) {
        let status = PetStatus(from: state)
        let kind: SpriteCatalog.AnimationKind = status.isSleeping ? .sleep : .idle
        let rows = SpriteCatalog.frames(for: status.species, kind: kind).first?.rows
            ?? [UInt16](repeating: 0, count: 16)
        self.init(
            date: date,
            speciesName: status.species.displayName,
            spriteRows: rows,
            hungerValue: status.hungerHearts.value,
            hungerMax: status.species.maxHunger,
            needsAttention: status.needsAttention,
            isInjured: status.isInjured,
            isDead: status.isDead,
            isEgg: status.isEgg,
            statusText: Self.mood(for: status)
        )
    }

    private static func mood(for status: PetStatus) -> String {
        if status.isDead { return "gone" }
        if status.isEgg { return "egg" }
        if status.isInjured { return "hurt" }
        if status.hungerHearts.isEmpty { return "hungry" }
        if status.strengthHearts.isEmpty { return "weak" }
        if status.poopCount > 0 { return "messy" }
        if status.isSleeping { return "asleep" }
        return "happy"
    }
}
