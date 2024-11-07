import SwiftUI
import ComposableArchitecture

@Reducer
struct TagDetailsFeature {
    @ObservableState
    struct State: Equatable {
        let tag: Tag
        var entries: [HistoryEntry] = []
    }

    enum Action {
        case getHistory
        case historyResponse([HistoryEntry])
        case didTapWriteButton
    }

    @Dependency(\.database) var database
    @Dependency(\.nfcSession) var nfcSession

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .getHistory:
                return .run { [state] send in
                    let entries = try await database.getHistory(state.tag)
                    await send(.historyResponse(entries))
                }
            case .historyResponse(let entries):
                state.entries = entries
                return .none
            case .didTapWriteButton:
                let tag = state.tag
                return .run { _ in
                    try await nfcSession.write(tag: tag)
                }
            }
        }
    }
}

