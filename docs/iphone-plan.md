# The iPhone companion

How the same pet comes to the phone after the watch ships (roadmap Epic 6),
written against the measured code rather than the hoped-for packages, so it
can start the week after launch whether or not the package split has
happened.

## What is already portable

Everything that is not WatchKit. Measured 2026-09-08:

| Layer | Files | iPhone-ready as it stands |
|---|---|---|
| Engine (models, simulation, actions, evolution, battle, persistence) | 39 | Yes — Foundation only |
| Sprites (frames, animator, catalog, art) | 29 | Yes |
| Presentation (presenters, view models, scene resolver) | 28 | Yes, except haptic calls |
| Views (screens, LCD canvas, components) | 26 | Yes, except the crown and two haptic calls |
| Health, Weather, Notifications, Settings, Power | 16 | Yes — HealthKit, WeatherKit, CoreLocation and UserNotifications are the same on iOS |
| Background, App entry | 3 | No — `WKApplicationDelegate`, `WKApplicationRefreshBackgroundTask`, `WKApplication.scheduleBackgroundRefresh` |
| Complication extension | 3 | Mostly — the accessory families exist on iOS as Lock Screen widgets; `.accessoryCorner` and `widgetLabel` are watch-only |

WatchKit is imported in 16 files, but 32 of its 40 uses are
`WKInterfaceDevice` haptics behind the one facade in
`Core/Extensions/WKInterfaceDevice+Haptics.swift`. Retargeting the facade
retargets the presenters.

## The four seams to cut

1. **Haptics.** Replace the facade's WatchKit body with a platform shim: on
   iOS `UIImpactFeedbackGenerator` / `UINotificationFeedbackGenerator`; the
   presenter call sites (`buttonHaptic`, `evolveHaptic`, …) do not change.
2. **App entry and background.** iOS gets its own `@main` with
   `UIApplicationDelegateAdaptor` and `BGTaskScheduler`
   (`BGAppRefreshTaskRequest`) in place of `WKApplicationRefreshBackgroundTask`.
   `BackgroundTick.perform` is already pure and platform-free; only
   `BackgroundRefreshScheduler.live()` and the delegate are rewritten.
3. **Input.** The Digital Crown selects the menu ring on the watch. On the
   phone the three buttons stay (they are the toy's buttons) and a horizontal
   swipe on the LCD stands in for the crown; both call
   `PetPresenter.selectMenu`. `.focusable()` and `.digitalCrownRotation` are
   wrapped in `#if os(watchOS)`.
4. **Layout.** The watch layout is 32×20 cells at a pixel size chosen for a
   40–49 mm face; the phone draws the same canvas larger inside a device
   bezel. Keep `LCDDisplay` untouched and give it a phone-sized frame.

## Sync: one creature, every screen

The engine is already shaped for it (roadmap, "Sync model"). The transport
decision is made here: **`NSUbiquitousKeyValueStore`**. The save is one
`PetStateDTO` of a few hundred bytes, far under the store's 1 MB total; it
needs no CloudKit container, no schema, and no server-side code. Rules:

- Both targets declare the same
  `com.apple.developer.ubiquity-kvstore-identifier` (the store is scoped by
  that entitlement and defaults to each target's own bundle id, so without a
  shared value the phone and the watch would sync with nobody).
- Every save writes the DTO to both `UserDefaults` (as today) and the
  ubiquitous store under one key; `didChangeExternallyNotification` reloads,
  and the `AccountChange` / `QuotaViolationChange` reasons are handled so an
  iCloud sign-out does not leave stale state. With no `ubiquityIdentityToken`
  (signed out) the app runs local-only, exactly as today.
- A fresh install never seeds a pet before the first download: hatch only
  when the initial sync (`InitialSyncChange` / `ServerChange`) has arrived
  and the key is absent. Otherwise a newborn stamped "now" would win the
  conflict below and overwrite the wearer's real pet.
- On conflict take the record with the newest `lastAdvancedAt`; the engine's
  catch-up replays any gap on the other device. No merge logic.
- Steps: the evolution accumulator, today's credited total and the tracked
  day all travel inside the DTO, so evolution progress is one number on
  both devices. Only the *live* count used for activity scaling is read
  locally, and the phone sees the watch's steps only when Health in iCloud
  is on (opt-in, minutes to hours of latency); otherwise the phone scales
  by its own pedometer. Accepted: the scaling is a rate, not the score.
- The complication timeline and the Lock Screen widget are each baked by
  their own app from the same DTO. iOS accessory widgets render masked
  (monochrome or accented); the baked sprite is already one-bit, so it
  carries over, but the views are redrawn rather than reused.

If the ubiquitous store ever proves too coarse (it syncs in seconds to
minutes, not instantly), CloudKit is the upgrade path and the DTO carries
over unchanged.

## Project shape

No new listing: the App Store Connect record is an iOS record already
(roadmap, Epic 0). The `watchapp2-container` stub target becomes a real
iOS app target with the same bundle id, `WKWatchOnly` comes off the watch
app, `WKCompanionAppBundleIdentifier` goes on, and the iOS target embeds the
watch app. **This conversion is one-way and, on update, auto-installs the
phone app on every paired iPhone** — a product decision to make
deliberately, not plumbing. The iOS target needs its own entitlements and
strings: HealthKit and WeatherKit capabilities, the health-share, location
and (if the pedometer is used) motion usage strings, the Apple Weather
attribution in its own UI, `UIBackgroundModes` fetch, and
`BGTaskSchedulerPermittedIdentifiers`, with `BGTaskScheduler.register`
called before launch finishes. Sources shared by both targets are added to
both memberships (or, once the package split lands, imported from the
packages). Estimated order:

1. iOS target with the haptics shim, a `ContentView` reusing the screens,
   and the four seams above — the pet runs on the phone, unsynced.
2. Ubiquitous-store sync behind the existing `PetStateStore` witness.
3. `BGTaskScheduler` background tick and the Lock Screen widget.
4. iPad: the same target with `TARGETED_DEVICE_FAMILY` 1,2; the LCD scales.
   No pedometer and no Taptic Engine, so steps arrive only through Health in
   iCloud and haptics are silent; HealthKit on iPad needs iPadOS 17 or later.

## Risks

- **Two engines, one pet.** Both devices may tick at once; the newest
  `lastAdvancedAt` wins and the loser's tick is discarded, which is safe
  because ticks are idempotent replays from the saved anchors. Actions
  (feed, clean) taken within the same sync window on both devices could
  double; acceptable for 1.x and worth a "last writer wins" note in the
  Settings About row.
- **Permissions twice.** HealthKit, location and notifications are granted
  per device; the Settings toggles are per device too, by design.
- **App Review re-review.** Adding an iOS app to the record is a new
  submission with iPhone screenshots, the same privacy answers, and its own
  HealthKit purpose justification in the review notes.
