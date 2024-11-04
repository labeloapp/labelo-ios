import SwiftUI
import ComposableArchitecture

@Reducer
struct ReadResultFeature {
    @ObservableState
    struct State: Equatable {
        let result: NFCSessionClient.ReadResult
    }

    @Dependency(\.openURL) var openURL

    enum Action {
        case open(URL)
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .open(let url):
                return .run { _ in
                    await openURL(url)
                }
            }
        }
    }
}
