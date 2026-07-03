import SwiftUI

struct SettingsScreen: View {

    let presenter: SettingsPresenter

    var body: some View {
        @Bindable var settings = presenter.settings
        List {
            Section("Display") {
                Toggle("Battery saver", isOn: $settings.batterySaverEnabled)
            }
            Section("Features") {
                Toggle("Notifications", isOn: $settings.notificationsEnabled)
                Toggle("Weather", isOn: $settings.weatherEnabled)
                Toggle("Steps", isOn: $settings.stepsEnabled)
                Toggle("Haptics", isOn: $settings.hapticsEnabled)
            }
            #if DEBUG
            debugSection
            #endif
        }
        .navigationTitle("Settings")
    }

    #if DEBUG
    @ViewBuilder
    private var debugSection: some View {
        Section("Debug") {
            Button("Cycle weather") { presenter.debug.cycleWeather() }
            Button("Force evolve") { presenter.debug.forceEvolve() }
            Button("Drain + care test") { presenter.debug.careTest() }
            Button("Kill pet", role: .destructive) { presenter.debug.killPet() }
        }
        Section("Morph into") {
            ForEach(PetSpecies.allCases) { species in
                Button(species.displayName) { presenter.debug.morph(species) }
            }
        }
    }
    #endif
}
