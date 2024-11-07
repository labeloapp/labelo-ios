import ComposableArchitecture

@DependencyClient
struct SpeechClient {
    var requestAuthorization: @Sendable () async throws -> Bool
    var speak: @Sendable (_ text: String) async throws -> Void
}

extension SpeechClient: DependencyKey {
    static let liveValue = SpeechClient.live
}

extension DependencyValues {
    var speechClient: SpeechClient {
        get { self[SpeechClient.self] }
        set { self[SpeechClient.self] = newValue }
    }
}
