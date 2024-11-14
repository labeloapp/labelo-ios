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
        @Presents var alert: AlertState<Action.Alert>?
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
        case alert(PresentationAction<Alert>)
        case showRetryAlert(_ error: (any Error)?)

        enum Alert: Equatable {
            case retry
            case dismiss
        }
    }

    @Dependency(\.database) var database
    @Dependency(\.nfcSession) var nfcSession
    @Dependency(\.uuid) var uuid

    var body: some Reducer<State, Action> {
        Reduce {
            state,
            action in
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
                state.createTag = TagCreateFeature.State(tag: Tag(id: uuid() , name: "Tag \(state.tags.count + 1)", payload: .text("This text will be written to the tag")))
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
                    do {
                        let result = try await nfcSession.read()
                        await send(.didRead(result))
                    } catch NFCSessionClientError.readError {
                        await send(.showRetryAlert(nil))
                    } catch NFCSessionClientError.failed(let error) {
                        await send(.showRetryAlert(error))
                    }
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
            case .alert(.presented(.retry)):
                return .run { send in
                    await send(.didTapReadButton)
                }
            case .alert(.presented(.dismiss)):
                state.alert = nil
                return .none
            case .alert:
                return .none
            case .showRetryAlert(let error):
                state.alert = createRetryAlertState(error)
                return .none
            }
        }
        .ifLet(\.$createTag, action: \.createTag) {
            TagCreateFeature()
        }
        .ifLet(\.$readResult, action: \.readResult) {
            ReadResultFeature()
        }
        .ifLet(\.$alert, action: \.alert)
        .forEach(\.path, action: \.path) {
            TagDetailsFeature()
        }
    }

    private func createRetryAlertState(_ error: (any Error)?) -> AlertState<Action.Alert> {
        let message: String
        if let error {
            message = "Reading failed \(error.localizedDescription). \nTry again?"
        } else {
            message = "Reading failed. \nTry again?"
        }

        return AlertState {
            TextState("Error reading the tag")
        } actions: {
            ButtonState(action: .retry) {
                TextState("Retry")
            }
            ButtonState(action: .dismiss) {
                TextState("Cancel")
            }
        } message: {
            TextState(message)
        }
    }
}
