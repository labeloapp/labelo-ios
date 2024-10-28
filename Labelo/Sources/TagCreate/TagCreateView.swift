import SwiftUI
import ComposableArchitecture

struct TagCreateView: View {
    @Bindable var store: StoreOf<TagCreateFeature>

    var body: some View {
        Form {
            TextField("Name", text: $store.tag.name.sending(\.setName))
            Button("Save") {
                store.send(.saveButtonTapped)
            }
        }
        .toolbar {
            ToolbarItem {
                Button("Cancel") {
                    store.send(.cancelButtonTapped)
                }
            }
        }
    }
}

