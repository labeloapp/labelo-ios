import SwiftUI
import ComposableArchitecture

struct TagListView: View {
    let store: StoreOf<TagListFeature>

    var body: some View {
        List(store.tags) { tag in
            VStack {
                Text(tag.name)
            }
        }
        .toolbar {
            Button("", systemImage: "plus") {
                store.send(.addTag(Tag(id: UUID().uuidString, name: "New Tag")))
            }
        }
    }
}
