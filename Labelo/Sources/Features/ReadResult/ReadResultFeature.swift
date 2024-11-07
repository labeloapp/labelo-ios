import SwiftUI
import ComposableArchitecture

@Reducer
struct ReadResultFeature {
    @ObservableState
    struct State: Equatable {
        @Shared(.appStorage("isAutoSpeechEnabled")) var isAutoSpeechEnabled: Bool = false
        let result: NFCSessionClient.ReadResult
        var isSpeaking = false
    }

    @Dependency(\.openURL) var openURL
    @Dependency(\.speechClient) var speechClient

    enum Action {
        case onAppear
        case open(URL)
        case didTapSpeakButton
        case setIsSpeaking(Bool)
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                if state.isAutoSpeechEnabled {
                    return .send(.didTapSpeakButton)
                }
                return .none
            case .open(let url):
                return .run { _ in
                    await openURL(url)
                }
            case .setIsSpeaking(let isSpeaking):
                state.isSpeaking = isSpeaking
                return .none
            case .didTapSpeakButton:
                let textToSpeak: String
                switch state.result {
                case .tag(let tag):
                    textToSpeak = tag.payload.stringValue
                case .text(let text):
                    textToSpeak = text
                case .url(let url):
                    textToSpeak = url.absoluteString
                case .empty:
                    textToSpeak = "Contents of the tag are empty"
                case .unknown:
                    textToSpeak = "Tag has a unknown content type"
                }

                return .run { send in
                    await send(.setIsSpeaking(true))
                    try await speechClient.speak(text: textToSpeak)
                    await send(.setIsSpeaking(false))
                }
            }
        }
    }
}
