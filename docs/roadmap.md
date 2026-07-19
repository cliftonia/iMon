# Release roadmap

The campaign plan for shipping this app to the App Store, and what follows it.
This document carries over to the new repository and is the single place the
plan lives; update it as epics close or decisions land.

## Vision

Ship the watch virtual pet to the App Store under a new name. Then bring the
same pet to iPhone and iPad as companions that stay **in sync with the watch**
— one creature, every screen. The watch remains the primary home: it is where
the steps are counted and the wrist is raised.

## Decisions made

- **Fresh repository, no history**, founded early rather than last — the
  rename is now also a restructure, so it happens once.
- **Architecture**: MVVMP retained; layers become compiler-enforced by moving
  to a workspace of thin app shells over local Swift packages (below).
- **Watch launch is not gated** on the iPhone/iPad work. Ship the wrist,
  then annex the pocket.

## Decisions pending

- **The name.** Front-runner: **Wristkin** (search-clear as of 2026-07-19).
  Also clear: Bitkin. Ruled out: Pipkin (existing creature-collector game).
  Avoid `-mon`/`-gotchi` endings — trademark adjacency. The only true claim
  is creating the App Store Connect app record; do that the day the name is
  chosen.
- **The pet hand-off.** A new bundle id strands the currently saved pet
  unless a one-time App Group hand-off ships in the new app.
- **Sync transport** (Epic 6): `NSUbiquitousKeyValueStore` (the DTO is tiny
  JSON, well under the 1 MB cap) vs CloudKit (more machinery, more control).
  Decide when the epic opens; the founding only needs to keep the DTO the
  single serialized form so either transport carries it unchanged.

## Target architecture

```
<Name>/
├── <Name>.xcworkspace
├── Apps/
│   ├── WatchApp/          thin shell: entry, DI wiring, platform shims
│   ├── WatchWidgets/      complication extension
│   ├── iOSApp/            (Epic 6) iPhone + iPad shell
│   └── iOSWidgets/        (Epic 6) home-screen widget, same timeline code
├── Packages/
│   ├── <Name>Core/        Tagged, TickMath, TimeConstants, logging → deps: none
│   ├── <Name>Engine/      models, simulation, actions, evolution,
│   │                      battle, persistence DTO                  → deps: Core
│   ├── <Name>Sprites/     frames, animator, catalog, shared art    → deps: Core, Engine
│   └── <Name>UI/          presenters, view models, LCD canvas,
│                          screens, components                      → deps: all above
├── Tools/                 sprite round-trip pipeline (carried over)
└── docs/                  this file, DOCUMENTATION.md (carried over)
```

Why: the Engine package cannot import WatchKit (layer purity by linker);
engine tests run via bare `swift test` with no simulator; the Engine package
skips MainActor default isolation so the explicit `nonisolated` markings
disappear; each new platform is one more thin shell over the same packages.

## Sync model (Epic 6 groundwork)

The engine is already shaped for sync. State is a value advanced by
`GameEngine.advance(state, to: .now)`, and the save is a flat versioned
`PetStateDTO`. Sync is therefore: ship the DTO, take the record with the
newest timestamp, and let the engine's catch-up replay close any gap — the
same mechanism that already handles the app being closed for eight hours.
No merge logic, no CRDTs. iPad note: HealthKit exists on iPadOS and step
data arrives via iCloud Health sync, so the loop works there too.

## Epic order

| # | Epic | Where | Why this position |
|---|------|-------|-------------------|
| 0 | Name + App Store Connect reservation, bundle ids, App Group | — | Blocks package naming; the name can be taken while we wait |
| 1 | Heal the state: step-count bug (5k vs 75), step-rollover loss, collapse-timing precision, DTO migration fields | old repo | These change the persisted schema — settle it **before** the migration so the save format moves once |
| 2 | The founding: fresh repo, workspace + packages, watch shell, hand-off if granted | new repo | Everything after lands in the new home |
| 3 | Deferred polish: defer-night-notifications, lifecycle items, debug-only items | new repo | No schema impact; benefits from the fast package test loop |
| 4 | Sprite treatment for Hopkin, Dotkin, Orbkin, Marshkin | new repo | Zero dependencies — runs parallel to Epic 3 |
| 5 | Watch submission: WeatherKit provisioning on the new App ID, privacy strings, icon, screenshots, TestFlight, App Review | new repo | Last, because every prior epic changes what the reviewer sees |
| 6 | Sync + iPhone/iPad shells: transport decision, `iOSApp` target, platform shims (haptics, `BGTaskScheduler`), home-screen widget | new repo | Post-launch (v1.x); the packages make it thin-shell work |

Epics 3 and 4 run in parallel; everything else is a chain.

## Standing risks

- **WeatherKit** needs the capability provisioned on the new App ID before
  release builds show live weather.
- **App Review**: HealthKit and notification usage strings must honestly
  describe the game loop; virtual-pet death mechanics are fine, but the
  metadata must not lean on trademarked franchises.
- **The stranded pet**: without the hand-off, launch day orphans the
  developer's own longest-lived creature. Decide with a clear heart.
