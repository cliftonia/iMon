import Foundation
import os
import Observation

@Observable
final class AppPresenter {

    // MARK: - State

    enum LifecyclePhase {
        case loading
        case hatching
        case alive
        case dead
    }

    private(set) var phase: LifecyclePhase = .loading
    private(set) var petPresenter: PetPresenter?
    private(set) var statsPresenter: StatsPresenter?
    private(set) var hatchPresenter: HatchPresenter?
    private(set) var deathPresenter: DeathPresenter?

    let router = AppRouter()

    private let store: PetStateStore

    // MARK: - Init

    init(store: PetStateStore = JSONPetStateStore.live()) {
        self.store = store
    }

    // MARK: - Lifecycle

    func onAppear() {
        loadOrStartNew()
    }

    private func loadOrStartNew() {
        do {
            if let saved = try store.load() {
                if saved.isDead {
                    startDeath(state: saved)
                } else if saved.isEgg {
                    startHatching()
                } else {
                    startAlive(state: saved)
                }
            } else {
                startHatching()
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
        let state = PetState.hatched(at: .now)
        startAlive(state: state)
    }

    private func startAlive(state: PetState) {
        phase = .alive
        let presenter = PetPresenter(state: state, store: store)
        petPresenter = presenter
        statsPresenter = StatsPresenter()
        hatchPresenter = nil
        deathPresenter = nil
        router.popToRoot()
    }

    private func startDeath(state: PetState) {
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
        presenter.update(from: petPresenter.getCurrentState())
        statsPresenter = presenter
        router.navigate(to: .stats)
    }

    /// Check if pet has died (called periodically by PetPresenter)
    func checkDeath() {
        guard let petPresenter else { return }
        let state = petPresenter.getCurrentState()
        if state.isDead {
            startDeath(state: state)
        }
    }
}
