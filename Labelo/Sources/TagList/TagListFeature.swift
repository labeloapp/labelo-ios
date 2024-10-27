import SwiftUI
import ComposableArchitecture

@Reducer
struct TagListFeature {
    @ObservableState
    struct State: Equatable {
        var tags: [Tag] = []
        var isLoading: Bool = false
    }

    enum Action {
        case getTags
        case tagResponse(tags: [Tag])
        case addTag(Tag)
    }

    @Dependency(\.database) var database

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .getTags:
                return .run { send in
                    let tags = try await self.database.getTags()
                    await send(.tagResponse(tags: tags))
                }
            case .tagResponse(let tags):
                state.tags = tags
                state.isLoading = false
            case .addTag(let tag):
                withAnimation {
                    state.tags.append(tag)
                }
                return .none
            }
            return .none
        }
    }
}
