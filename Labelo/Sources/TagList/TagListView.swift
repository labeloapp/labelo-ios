import SwiftUI
import ComposableArchitecture

struct TagListView: View {
    @Bindable var store: StoreOf<TagListFeature>

    var body: some View {
        List(store.tags, id: \.id) { tag in
            Text(tag.name)
                .swipeActions {
                    Button(role: .destructive) {
                        store.send(.delete(tag))
                    } label: {
                        Text("Delete")
                    }
                }
        }
        .navigationTitle("Tags")
        .disabled(store.isLoading)
        .overlay {
            if store.isLoading {
                ProgressView()
            } else if store.tags.isEmpty {
                ContentUnavailableView.search
            }
        }
        .onAppear {
            store.send(.getTags)
        }
        .toolbar {
            Button("", systemImage: "plus") {
                store.send(.addButtonTapped)
            }
        }
        .sheet(item: $store.scope(state: \.createTag, action: \.createTag)) { tagCreateStore in
            NavigationStack {
                TagCreateView(store: tagCreateStore)
            }
        }
    }
}
