import Foundation
import os
import Observation

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

            // Catch the saved pet up to now *before* the first render, so the
            // scene (day/night, sleep) is current immediately - no stale-night
            // flash - and a death that happened while away is surfaced at once.
            let advanced = GameEngine.advance(
                saved, to: .now,
                isNight: weatherStore.nightSignal(),
                steps: stepActivityStore.todaySteps
            )
            try? store.save(advanced)

            if advanced.isDead {
                startDeath(state: advanced)
            } else {
                startAlive(state: advanced)
            }
        } catch {
            Log.presentation.error("Failed to load state: \(error)")
            startHatching()
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
        startAlive(state: PetState.hatched(at: .now))
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
            onDeath: { [weak self] in self?.checkDeath() }
        )
        petPresenter = presenter
        statsPresenter = StatsPresenter()
        hatchPresenter = nil
        onboardingPresenter = nil
        deathPresenter = nil
        router.popToRoot()
    }

    private func startDeath(state: PetState) {
        // Pop any pushed screen (e.g. Stats) first, or the grave would appear
        // underneath it when the pet dies mid-navigation.
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
            Log.presentation.error("Failed to delete state: \(error)")
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
        // Debug actions pop back to the pet screen first, so their effect (the
        // evolution sheet, the drained pet, the grave) is visible straight away.
        let presenter = SettingsPresenter(settings: settings, debug: SettingsDebugActions(
            cycleWeather: { [weatherStore] in weatherStore.cycleDebugCondition() },
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

    /// Check if pet has died after a debug evolution cycle.
    func checkDeath() {
        guard let petPresenter else { return }
        let state = petPresenter.getCurrentState()
        if state.isDead {
            startDeath(state: state)
        }
    }

    /// Reset the current pet back to a fresh egg (the ⚠️ menu button).
    func restartPet() {
        #if DEBUG
        // Debug: kill the pet instead of resetting, so the Death screen can be
        // verified on demand. "New Egg" there still starts a fresh pet.
        if let petPresenter {
            var state = petPresenter.getCurrentState()
            state.isDead = true
            try? store.save(state)
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
