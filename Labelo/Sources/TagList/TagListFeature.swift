import SwiftUI
import ComposableArchitecture

@Reducer
struct TagListFeature {
    @ObservableState
    struct State: Equatable {
        var tags: [Tag] = []
        var isLoading: Bool = false
        @Presents var createTag: TagCreateFeature.State?
    }

    enum Action {
        case getTags
        case tagResponse(tags: [Tag])
        case addButtonTapped
        case addTag(Tag)
        case createTag(PresentationAction<TagCreateFeature.Action>)
        case delete(Tag)
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
                return .none
            case .addButtonTapped:
                state.createTag = TagCreateFeature.State()
                return .none
            case .addTag(let tag):
                withAnimation {
                    state.tags.append(tag)
                }
                return .none
            case let .createTag(.presented(.delegate(.saveTag(tag)))):
                state.createTag = nil
                return .run { send in
                    try await database.save(tag: tag)
                    await send(.getTags)
                }
            case .createTag(.presented(.delegate(.cancel))):
                state.createTag = nil
                return .none
            case .createTag:
                return .none
            case .delete(let tag):
                return .run { send in
                    try await database.delete(tag: tag)
                    await send(.getTags)
                }
            }
        }
        .ifLet(\.$createTag, action: \.createTag) {
            TagCreateFeature()
        }
    }
}
