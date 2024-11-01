import SwiftUI
import ComposableArchitecture

@Reducer
struct TagCreateFeature {
    enum PayloadType: String, CaseIterable {
        case text = "text"
        case url = "URL"

        var defaultPayload: Tag.Payload {
            switch self {
            case .text: return .text("")
            case .url: return .url(URL(string: "https://example.com")!)
            }
        }
    }

    @ObservableState
    struct State: Equatable {
        var tag = Tag(name: "", payload: .text(""))
        var type: PayloadType = .text
        var urlString: String = ""
        var focus: Field?
        var isNameError = false
        var isPayloadError = false

        enum Field: Hashable {
            case name
            case text
            case url
        }
    }

    enum Action {
        case setName(String)
        case setPayload(PayloadType)
        case setPayloadText(String)
        case setPayloadURL(String)
        case writeButtonTapped
        case cancelButtonTapped
        case delegate(Delegate)

        enum Delegate: Equatable {
            case cancel
            case saveTag(Tag)
        }
    }

    @Dependency(\.nfcSession) var nfcSession

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .setName(let name):
                state.tag.name = name
                state.isNameError = false
                return .none
            case .setPayload(let payloadType):
                state.isPayloadError = false
                state.type = payloadType
                state.tag.payload = payloadType.defaultPayload
                return .none
            case .setPayloadText(let text):
                state.tag.payload = .text(text)
                state.isPayloadError = false
                return .none
            case .setPayloadURL(let url):
                state.urlString = url
                state.isPayloadError = false
                return .none
            case .writeButtonTapped:
                if state.tag.name.isEmpty {
                    state.isNameError = true
                }

                switch state.type {
                case .url:
                    guard let url = URL(string: state.urlString) else {
                        state.isPayloadError = true
                        return .none
                    }
                    state.tag.payload = .url(url)
                case .text:
                    guard case .text(let text) = state.tag.payload, !text.isEmpty else {
                        state.isPayloadError = true
                        return .none
                    }
                }

                guard !state.isNameError, !state.isPayloadError else { return .none }

                return .run { [state] send in
                    try await nfcSession.write(state.tag)
                    await send(.delegate(.saveTag(state.tag)))
                }
            case .cancelButtonTapped:
                return .send(.delegate(.cancel))
            case .delegate:
                return .none
            }
        }
    }
}
