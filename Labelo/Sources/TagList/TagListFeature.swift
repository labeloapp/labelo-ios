import SwiftUI
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

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
                case .addTag(let tag):
                withAnimation {
                    state.tags.append(tag)
                }
                return .none
            }
        }
    }
}
