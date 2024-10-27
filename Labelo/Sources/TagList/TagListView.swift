import SwiftUI
import ComposableArchitecture

struct TagListView: View {
    let store: StoreOf<TagListFeature>

    var body: some View {
        List(store.tags, id: \.id) { tag in
            Text(tag.name)
        }
        .disabled(store.isLoading)
        .overlay {
            if store.isLoading {
                ProgressView()
            }
        }
        .onAppear {
            store.send(.getTags)
        }
        .toolbar {
            Button("", systemImage: "plus") {
                store.send(.addTag(Tag(id: UUID().uuidString, name: "New Tag")))
            }
        }
    }
}
