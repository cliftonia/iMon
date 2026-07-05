import SwiftUI

struct ContentView: View {
    @State private var appPresenter = AppPresenter()
    @State private var powerSaver = PowerSaverStore.live()

    /// The manual Settings switch or the system Low Power Mode - either turns on
    /// the red palette.
    private var batterySaverActive: Bool {
        appPresenter.settings.batterySaverEnabled || powerSaver.isActive
    }

    var body: some View {
        @Bindable var router = appPresenter.router
        NavigationStack(path: $router.path) {
            Group {
                switch appPresenter.phase {
                case .loading:
                    ProgressView()
                        .accessibilityLabel("Loading")

                case .hatching:
                    if let hatchPresenter = appPresenter.hatchPresenter {
                        HatchScreen(presenter: hatchPresenter)
                    }

                case .onboarding:
                    if let onboardingPresenter = appPresenter.onboardingPresenter {
                        OnboardingScreen(presenter: onboardingPresenter)
                    }

                case .alive:
                    if let petPresenter = appPresenter.petPresenter {
                        PetScreen(presenter: petPresenter)
                            .environment(appPresenter)
                    }

                case .dead:
                    if let deathPresenter = appPresenter.deathPresenter {
                        DeathScreen(presenter: deathPresenter)
                    }
                }
            }
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .stats:
                    if let statsPresenter = appPresenter.statsPresenter {
                        StatsScreen(presenter: statsPresenter)
                    }

                case .settings:
                    if let settingsPresenter = appPresenter.settingsPresenter {
                        SettingsScreen(presenter: settingsPresenter)
                    }
                }
            }
        }
        .environment(\.lcdTheme, batterySaverActive ? .nightRed : .classic)
        .task {
            appPresenter.onAppear()
        }
        .task {
            // Recolour live when Low Power Mode toggles (mapped to Void so no
            // non-Sendable Notification crosses the actor boundary).
            let changes = NotificationCenter.default
                .notifications(named: .NSProcessInfoPowerStateDidChange)
                .map { _ in () }
            for await _ in changes {
                powerSaver.refresh()
            }
        }
    }
}
