import Foundation
import os
import Observation

/// The app's lifecycle phase machine. Resolves the saved pet into a
/// `LifecyclePhase` on launch and owns the presenter for whichever phase is
/// showing. Phases replace one another (hatch → onboarding → alive → dead →
/// hatch) rather than stacking, which is why lifecycle screens are not
/// `AppRoute`s — only stats and settings push onto the `NavigationStack`.
@Observable
final class AppPresenter {

    // MARK: - State

    enum LifecyclePhase {
        case loading
        case hatching
        case onboarding
        case alive
        case dead
    }

    private(set) var phase: LifecyclePhase = .loading
    private(set) var petPresenter: PetPresenter?
    private(set) var statsPresenter: StatsPresenter?
    private(set) var settingsPresenter: SettingsPresenter?
    private(set) var hatchPresenter: HatchPresenter?
    private(set) var onboardingPresenter: OnboardingPresenter?
    /// The newborn saved at hatch, carried through the walkthrough.
    private var hatchedState: PetState?
    private(set) var deathPresenter: DeathPresenter?

    let router = AppRouter()
    let weatherStore: WeatherStore
    let stepActivityStore: StepActivityStore
    let settings: SettingsStore

    private let store: PetStateStore

    // MARK: - Init

    init(
        store: PetStateStore = JSONPetStateStore.live(),
        weatherStore: WeatherStore = .makeDefault(),
        stepActivityStore: StepActivityStore = .makeDefault(),
        settings: SettingsStore = SettingsStore()
    ) {
        self.store = store
        self.weatherStore = weatherStore
        self.stepActivityStore = stepActivityStore
        self.settings = settings
    }

    // MARK: - Lifecycle

    func onAppear() {
        loadOrStartNew()
    }

    private func loadOrStartNew() {
        do {
            guard let saved = try store.load() else {
                startHatching()
                return
            }
            if saved.isEgg {
                startHatching()
                return
            }

            // Advance before first render — no stale-night flash; away deaths surface at once.
            let advanced = GameEngine.advance(
                saved, to: .now,
                isNight: weatherStore.nightSignal(),
                steps: stepActivityStore.todaySteps
            )
            persist(advanced)

            if advanced.isDead {
                startDeath(state: advanced)
            } else {
                startAlive(state: advanced)
            }
        } catch {
            Log.presentation.error("Failed to load state: \(error, privacy: .public)")
            startHatching()
        }
    }

    /// Saves through a logged funnel — a silent save failure here would lose
    /// the pet (or its catch-up) with no signal.
    private func persist(_ state: PetState) {
        do {
            try store.save(state)
        } catch {
            Log.presentation.error("Failed to save state: \(error, privacy: .public)")
        }
    }

    // MARK: - Phase Transitions

    private func startHatching() {
        phase = .hatching
        hatchPresenter = HatchPresenter { [weak self] in
            self?.onHatchComplete()
        }
    }

    private func onHatchComplete() {
        // Persist before onboarding — quitting mid-walkthrough must not lose the pet.
        let state = PetState.hatched(at: .now)
        persist(state)
        hatchedState = state
        startOnboarding()
    }

    private func startOnboarding() {
        phase = .onboarding
        hatchPresenter = nil
        onboardingPresenter = OnboardingPresenter { [weak self] in
            self?.finishOnboarding()
        }
    }

    private func finishOnboarding() {
        onboardingPresenter = nil
        startAlive(state: hatchedState ?? PetState.hatched(at: .now))
        hatchedState = nil
    }

    private func startAlive(state: PetState) {
        phase = .alive
        let presenter = PetPresenter(
            state: state,
            store: store,
            currentNight: { [weatherStore, settings] in
                // Weather off -> no night signal, so day/night falls back to the clock.
                settings.weatherEnabled ? weatherStore.nightSignal() : nil
            },
            currentSteps: { [stepActivityStore, settings] in
                // Steps off -> no reading, so no step bonuses accrue.
                settings.stepsEnabled ? stepActivityStore.todaySteps : nil
            },
            finalSteps: { [stepActivityStore, settings] day in
                settings.stepsEnabled ? await stepActivityStore.finalSteps(for: day) : nil
            },
            onDeath: { [weak self] in self?.checkDeath() }
        )
        petPresenter = presenter
        hatchPresenter = nil
        onboardingPresenter = nil
        deathPresenter = nil
        router.popToRoot()
    }

    private func startDeath(state: PetState) {
        // Pop first — the grave must not appear beneath a pushed screen (e.g. Stats).
        router.popToRoot()
        phase = .dead
        deathPresenter = DeathPresenter(state: state, onRestart: { [weak self] in
            self?.onRestart()
        })
        petPresenter?.stopGameLoop()
        petPresenter = nil
    }

    private func onRestart() {
        do {
            try store.delete()
        } catch {
            Log.presentation.error("Failed to delete state: \(error, privacy: .public)")
        }
        startHatching()
    }

    // MARK: - Navigation Actions

    func navigateToStats() {
        guard let petPresenter else { return }
        let presenter = StatsPresenter()
        presenter.update(
            from: petPresenter.getCurrentState(),
            steps: stepActivityStore.todaySteps
        )
        statsPresenter = presenter
        router.navigate(to: .stats)
    }

    func navigateToSettings() {
        #if DEBUG
        // Debug actions pop to the pet screen first so their effect is visible at once.
        let presenter = SettingsPresenter(settings: settings, debug: SettingsDebugActions(
            setWeather: { [weak self, weatherStore] condition in
                self?.router.popToRoot()
                weatherStore.setDebugCondition(condition)
            },
            forceEvolve: { [weak self] in self?.router.popToRoot(); self?.petPresenter?.debugEvolve() },
            careTest: { [weak self] in self?.router.popToRoot(); self?.petPresenter?.debugCareTest() },
            killPet: { [weak self] in self?.restartPet() },
            morph: { [weak self] species in
                self?.router.popToRoot()
                self?.petPresenter?.debugMorph(into: species)
            }
        ))
        #else
        let presenter = SettingsPresenter(settings: settings)
        #endif
        settingsPresenter = presenter
        router.navigate(to: .settings)
    }

    /// The `onDeath` hook from `PetPresenter` — re-reads the live state and
    /// flips to the death phase if the pet has died.
    func checkDeath() {
        guard let petPresenter else { return }
        let state = petPresenter.getCurrentState()
        if state.isDead {
            startDeath(state: state)
        }
    }

    /// Resets the current pet back to a fresh egg (the ⚠️ menu button).
    func restartPet() {
        #if DEBUG
        // Kill instead of reset in DEBUG so the Death screen is verifiable on demand.
        if let petPresenter {
            var state = petPresenter.getCurrentState()
            state.isDead = true
            persist(state)
            petPresenter.stopGameLoop()
            self.petPresenter = nil
            startDeath(state: state)
            return
        }
        #endif
        petPresenter?.stopGameLoop()
        petPresenter = nil
        onRestart()
    }
}
