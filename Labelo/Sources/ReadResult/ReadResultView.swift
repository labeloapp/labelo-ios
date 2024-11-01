import SwiftUI
import ComposableArchitecture

struct ReadResultView: View {
    @Bindable var store: StoreOf<ReadResultFeature>

    var body: some View {
        Form {
            switch store.result {
            case .text(let text):
                Section("Text") {
                    Text(text)
                }
            case .url(let url):
                Section("URL") {
                    Button {
                        store.send(.open(url))
                    } label: {
                        Text(url.absoluteString)
                    }
                }
            case .empty:
                ContentUnavailableView("Tag is empty", systemImage: "radiowaves.right")
            case .unknown:
                ContentUnavailableView("Couldn't decode tag data", systemImage: "radiowaves.right")
            }
        }
    }
}
