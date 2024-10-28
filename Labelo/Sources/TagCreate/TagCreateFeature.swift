import SwiftUI
import ComposableArchitecture

@Reducer
struct TagCreateFeature {
    @ObservableState
    struct State: Equatable {
        var tag = Tag(name: "New Tag")
    }

    enum Action {
        case setName(String)
        case saveButtonTapped
        case cancelButtonTapped
        case delegate(Delegate)

        enum Delegate: Equatable {
            case cancel
            case saveTag(Tag)
        }
    }

    @Dependency(\.database) var database

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .setName(let name):
                state.tag.name = name
                return .none
            case .saveButtonTapped:
                return .send(.delegate(.saveTag(state.tag)))
            case .cancelButtonTapped:
                return .send(.delegate(.cancel))
            case .delegate:
                return .none
            }
        }
    }
}
