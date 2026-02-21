import SwiftUI

struct ContentView: View {
    @State private var appPresenter = AppPresenter()

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

                case .pet, .hatch, .death:
                    EmptyView()
                }
            }
        }
        .task {
            appPresenter.onAppear()
        }
    }
}
