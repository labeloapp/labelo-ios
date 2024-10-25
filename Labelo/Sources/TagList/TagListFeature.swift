import ComposableArchitecture

@Reducer
struct TagListFeature {
    @ObservableState
    struct State: Equatable {
        var tags: [Tag] = Tag.mocks
    }

    enum Action {
        case addTag(Tag)
    }

    var body: some Reducer {
        Reduce { state, action in
            switch action {
                case .addTag(let tag):
                state.tags.append(tag)
                return .none
            }
        }
    }
}
