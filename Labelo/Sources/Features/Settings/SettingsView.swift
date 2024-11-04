import SwiftUI
import ComposableArchitecture

struct SettingsView: View {
    @Bindable var store: StoreOf<SettingsFeature>

    var body: some View {
        NavigationView {
            Form {
                // TODO: Implement
            }
            .navigationTitle("Settings")
        }
    }
}
