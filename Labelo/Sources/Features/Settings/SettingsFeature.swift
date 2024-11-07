import Foundation
import ComposableArchitecture

@Reducer
struct SettingsFeature {
    @ObservableState
    struct State: Equatable {
        @Shared(.appStorage("isAutoSpeechEnabled")) var isAutoSpeechEnabled: Bool = false
    }

    enum Action {
        case setIsAutoSpeechEnabled(Bool)
        case openURL(URL)
    }

    @Dependency(\.openURL) var openURL

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .openURL(let url):
                return .run { send in
                    await openURL(url)
                }
            case .setIsAutoSpeechEnabled(let isEnabled):
                state.isAutoSpeechEnabled = isEnabled
                return .none
            }
        }
    }
}
