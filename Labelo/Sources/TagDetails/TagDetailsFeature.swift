import SwiftUI
import ComposableArchitecture

@Reducer
struct TagDetailsFeature {
    @ObservableState
    struct State: Equatable {
        let tag: Tag
    }

    enum Action {}

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            return .none
        }
    }
}

