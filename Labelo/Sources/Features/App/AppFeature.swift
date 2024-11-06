import ComposableArchitecture

enum LabeloTab: String, Equatable {
    case list
    case settings
}

@Reducer
struct AppFeature {
    @ObservableState
    struct State: Equatable {
        var selectedTab: LabeloTab = .list
        var listState = TagListFeature.State()
        var settingsState = SettingsFeature.State()
    }

    enum Action {
        case selectTab(LabeloTab)
        case listAction(TagListFeature.Action)
        case settingsAction(SettingsFeature.Action)
    }

    var body: some Reducer<State, Action> {
        Scope(state: \.listState, action: \.listAction) {
            TagListFeature()
        }

        Scope(state: \.settingsState, action: \.settingsAction) {
            SettingsFeature()
        }

        Reduce { state, action in
            switch action {
            case .selectTab(let tab):
                state.selectedTab = tab
                return .none
            default :
                return .none
            }
        }
    }
}
