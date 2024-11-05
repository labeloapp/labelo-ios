import SwiftUI
import ComposableArchitecture

struct TagListView: View {
    @Bindable var store: StoreOf<TagListFeature>

    var body: some View {
        NavigationStackStore(store.scope(state: \.path, action: \.path)) {
            List(store.tags, id: \.id) { tag in
                NavigationLink(state: TagDetailsFeature.State(tag: tag)) {
                    Text(tag.name)
                        .swipeActions {
                            Button(role: .destructive) {
                                store.send(.delete(tag))
                            } label: {
                                Text("Delete")
                            }
                        }
                }
            }
            .navigationTitle("Tags")
            .disabled(store.isLoading)
            .overlay {
                if store.isLoading {
                    ProgressView()
                } else if store.tags.isEmpty {
                    ContentUnavailableView("No created tags yet", systemImage: "radiowaves.right")
                }
            }
            .safeAreaInset(edge: .bottom) {
                readButton
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
            .sheet(item: $store.scope(state: \.readResult, action: \.readResult)) { store in
                ReadResultView(store: store)
            }
        } destination: { store in
            TagDetailsView(store: store)
        }
    }

    var readButton: some View {
        Button {
            store.send(.didTapReadButton)
        } label: {
            Label("READ TAG", systemImage: "radiowaves.right")
                .font(.body)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity)
        }
        .frame(height: 60)
        .buttonStyle(.borderedProminent)
        .padding(.horizontal, 16)
    }
}