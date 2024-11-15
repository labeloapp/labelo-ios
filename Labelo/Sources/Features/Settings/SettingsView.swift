import SwiftUI
import ComposableArchitecture
import StoreKit

struct SettingsView: View {
    @Environment(\.requestReview) private var requestReview
    @Bindable var store: StoreOf<SettingsFeature>

    var body: some View {
        NavigationView {
            Form {
                Section("Rate") {
                    LabeledContent("Rate Labelo") {
                        Button {
                            requestReview()
                        } label: {
                            Image(systemName: "star.fill")
                                .resizable()
                                .frame(width: 20, height: 20)
                        }
                    }
                }
                Section {
                    LabeledContent("Auto Speech") {
                        Toggle("", isOn: $store.isAutoSpeechEnabled.sending(\.setIsAutoSpeechEnabled))
                    }
                } header: {
                    Text("App Settings")
                } footer: {
                    Text("If auto speech is enabled the results of the tag you read will be spoken out loud automatically.")
                }

                Section {
                    LabeledContent("Join our chat") {
                        Button {
                            store.send(.openURL(URL(string: "https://t.me/labeloapp")!))
                        } label: {
                            Image(systemName: "paperplane.fill")
                                .resizable()
                                .frame(width: 20, height: 20)
                        }
                    }
                } header: {
                    Text("Support")
                } footer: {
                    Text("Join our telegram chat to report bugs, give feedback or suggest improvements.")
                }
            }
            .navigationTitle("Settings")
        }
        .navigationViewStyle(.stack)
    }
}
