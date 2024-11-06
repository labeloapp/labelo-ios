import SwiftUI
import ComposableArchitecture
import StoreKit

struct SettingsView: View {
    @Environment(\.requestReview) private var requestReview
    @Bindable var store: StoreOf<SettingsFeature>

    var body: some View {
        NavigationView {
            Form {
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
            .navigationTitle("Settings")
        }
    }
}
