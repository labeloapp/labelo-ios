import SwiftUI
import ComposableArchitecture

@Reducer
struct TagListFeature {
    @ObservableState
    struct State: Equatable {
        var tags: [Tag] = []
        var isLoading: Bool = false
        @Presents var createTag: TagCreateFeature.State?
        @Presents var readResult: ReadResultFeature.State?
        var path = StackState<TagDetailsFeature.State>()
    }

    enum Action {
        case createTag(PresentationAction<TagCreateFeature.Action>)
        case readResult(PresentationAction<ReadResultFeature.Action>)
        case path(StackAction<TagDetailsFeature.State, TagDetailsFeature.Action>)
        case getTags
        case tagResponse(tags: [Tag])
        case addButtonTapped
        case addTag(Tag)
        case delete(Tag)
        case didTapReadButton
        case didRead(NFCSessionClient.ReadResult)
    }

    @Dependency(\.database) var database
    @Dependency(\.nfcSession) var nfcSession
    @Dependency(\.uuid) var uuid

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
                state.createTag = TagCreateFeature.State(tag: Tag(id: uuid() , name: "", payload: .text("")))
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
            case .didTapReadButton:
                return .run { send in
                    let result = try await nfcSession.read()
                    await send(.didRead(result))
                }
            case .didRead(let result):
                state.readResult = ReadResultFeature.State(result: result)

                if case .tag(let tag) = result {
                    return .run { _ in
                        let entry = HistoryEntry(tag: tag, readAt: .now)
                        try await database.saveHistoryEntry(entry)
                    }
                }

                return .none
            case .readResult:
                return .none
            case .path:
                return .none
            }
        }
        .ifLet(\.$createTag, action: \.createTag) {
            TagCreateFeature()
        }
        .ifLet(\.$readResult, action: \.readResult) {
            ReadResultFeature()
        }
        .forEach(\.path, action: \.path) {
            TagDetailsFeature()
        }
    }
}
