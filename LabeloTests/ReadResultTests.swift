import Foundation
import ComposableArchitecture
import Testing

@testable import Labelo

@MainActor
@Suite("Read Result Tests")
struct ReadResultTests {
    @Test
    func testDidTapSpeakButton() async throws {
        let result = NFCSessionClient.ReadResult.tag(.init(name: "test", payload: .text("test")))

        await confirmation { confirmation in

            let testClient = SpeechClient {
                return true
            } speak: { text in
                #expect(text == "test")
                confirmation()
            }

            let store = TestStore(initialState: ReadResultFeature.State(result: result)) {
                ReadResultFeature()
            } withDependencies: {
                $0.speechClient = testClient
            }

            store.exhaustivity = .off

            await store.send(.didTapSpeakButton)
        }
    }

    @Test func testOpenURL() async throws {
        let url = URL(string: "https://example.com")!
        let result = NFCSessionClient.ReadResult.tag(.init(name: "test", payload: .url(url)))

        await confirmation { confirmation in

            let testOpenURL = OpenURLEffect { _ in
                #expect(url == url)
                confirmation()
                return true
            }

            let store = TestStore(initialState: ReadResultFeature.State(result: result)) {
                ReadResultFeature()
            } withDependencies: {
                $0.openURL = testOpenURL
            }

            store.exhaustivity = .off

            await store.send(.open(url))
        }
    }

    @Test func tes() async throws {
        let url = URL(string: "https://example.com")!
        let result = NFCSessionClient.ReadResult.tag(.init(name: "test", payload: .url(url)))

        let testClient = SpeechClient {
            return true
        } speak: { _ in
        }



        let store = TestStore(initialState: ReadResultFeature.State(isAutoSpeechEnabled: true, result: result)) {
            ReadResultFeature()
        } withDependencies: {
            $0.speechClient = testClient
        }

        store.exhaustivity = .off

        await store.send(.onAppear)
        await store.receive(\.didTapSpeakButton)
        await store.receive(\.setIsSpeaking, true)
        await store.receive(\.setIsSpeaking, false)
    }
}

