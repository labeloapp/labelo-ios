import SwiftUI
import ComposableArchitecture

struct AppView: View {
    @Bindable var store: StoreOf<AppFeature>

    var body: some View {
        TabView(selection: $store.selectedTab.sending(\.selectTab)) {
            Tab("Tags", systemImage: "radiowaves.right", value: LabeloTab.list) {
                TagListView(store: store.scope(state: \.listState, action: \.listAction))
            }
            Tab("Settings", systemImage: "gear", value: LabeloTab.settings) {
                SettingsView(store: store.scope(state: \.settingsState, action: \.settingsAction))
            }
        }
        .onOpenURL { url in
            print(url.absoluteString)
        }
    }
}
