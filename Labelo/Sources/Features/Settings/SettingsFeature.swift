import ComposableArchitecture

@Reducer
struct SettingsFeature {
    @ObservableState
    struct State: Equatable {
        @Shared(.appStorage("isAutoSpeechEnabled")) var isAutoSpeechEnabled: Bool = false
    }

    enum Action {
        case setIsAutoSpeechEnabled(Bool)
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .setIsAutoSpeechEnabled(let isEnabled):
                state.isAutoSpeechEnabled = isEnabled
                return .none
            }
        }
    }
}
