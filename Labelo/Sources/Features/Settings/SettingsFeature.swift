import ComposableArchitecture

@Reducer
struct SettingsFeature {
    @ObservableState
    struct State: Equatable {}

    enum Action {}

    var body: some Reducer<Self> {
        Reduce { state, action in
            // TODO: Implement
            return .none
        }
    }
}
