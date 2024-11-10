import Foundation
import ComposableArchitecture
import Testing

@testable import Labelo

@MainActor
@Suite("Tag Create Tests")
struct TagCreateTests {
    @Test
    func testSetName() async throws {
        let testNFCSession = NFCSessionClient { _ in

        } read: {
            return .empty
        }

        let store = TestStore(initialState: TagCreateFeature.State(tag: .empty)) {
            TagCreateFeature()
        } withDependencies: {
            $0.nfcSession = testNFCSession
        }

        store.exhaustivity = .off

        await store.send(.setName("test")) {
            $0.tag.name = "test"
        }

        await store.send(.writeButtonTapped) {
            $0.isNameError = false
        }

        await store.send(.setName("")) {
            $0.tag.name = ""
        }

        await store.send(.writeButtonTapped) {
            $0.isNameError = true
        }
    }

    @Test
    func testSetPayload() async throws {
        let testNFCSession = NFCSessionClient { _ in

        } read: {
            return .empty
        }

        let store = TestStore(initialState: TagCreateFeature.State(tag: .empty)) {
            TagCreateFeature()
        } withDependencies: {
            $0.nfcSession = testNFCSession
        }

        store.exhaustivity = .off

        await store.send(.setPayload(.text)) {
            $0.type = .text
            $0.tag.payload = TagCreateFeature.PayloadType.text.defaultPayload
        }

        await store.send(.setPayload(.url)) {
            $0.type = .url
            $0.tag.payload = TagCreateFeature.PayloadType.url.defaultPayload
        }
    }

    @Test
    func testSetPayloadText() async throws {
        let testNFCSession = NFCSessionClient { _ in
        } read: {
            return .empty
        }

        let store = TestStore(initialState: TagCreateFeature.State(tag: .empty)) {
            TagCreateFeature()
        } withDependencies: {
            $0.nfcSession = testNFCSession
        }

        store.exhaustivity = .off

        await store.send(.setPayloadText("test")) {
            $0.tag.payload = .text("test")
        }
    }

    @Test
    func testSetPayloadURL() async throws {
        let testNFCSession = NFCSessionClient { _ in
        } read: {
            return .empty
        }

        let store = TestStore(initialState: TagCreateFeature.State(tag: .empty)) {
            TagCreateFeature()
        } withDependencies: {
            $0.nfcSession = testNFCSession
        }

        store.exhaustivity = .off

        await store.send(.setPayloadURL("https://example.com")) {
            $0.urlString = "https://example.com"
        }
    }

    @Test
    func testWriteNameIsEmpty() async throws {
        let testNFCSession = NFCSessionClient { _ in
        } read: {
            return .empty
        }

        let store = TestStore(initialState: TagCreateFeature.State(tag: .empty)) {
            TagCreateFeature()
        } withDependencies: {
            $0.nfcSession = testNFCSession
        }

        store.exhaustivity = .off

        await store.send(.writeButtonTapped) {
            $0.isPayloadError = true
        }
    }

    @Test
    func testWritePayloadTextIsEmpty() async throws {
        let testNFCSession = NFCSessionClient { _ in
        } read: {
            return .empty
        }

        let store = TestStore(initialState: TagCreateFeature.State(tag: .init(name: "Test", payload: .text("")))) {
            TagCreateFeature()
        } withDependencies: {
            $0.nfcSession = testNFCSession
        }

        store.exhaustivity = .off

        await store.send(.writeButtonTapped) {
            $0.isPayloadError = true
        }
    }

    @Test
    func testWritePayloadText() async throws {
        let testNFCSession = NFCSessionClient { _ in
        } read: {
            return .empty
        }
        let tag = Tag(name: "Test", payload: .text("test"))

        let store = TestStore(initialState: TagCreateFeature.State(tag: tag)) {
            TagCreateFeature()
        } withDependencies: {
            $0.nfcSession = testNFCSession
        }

        await store.send(.writeButtonTapped)
        await store.receive(\.delegate, .saveTag(tag))
    }

    @Test
    func testWritePayloadURLNotValid() async throws {
        let testNFCSession = NFCSessionClient { _ in
        } read: {
            return .empty
        }
        let tag = Tag(name: "Test", payload: .url(URL(string: "https://example.com")!))

        let store = TestStore(initialState: TagCreateFeature.State(tag: tag, type: .url)) {
            TagCreateFeature()
        } withDependencies: {
            $0.nfcSession = testNFCSession
        }

        store.exhaustivity = .off

        await store.send(.setPayloadURL("   l"))
        await store.send(.writeButtonTapped) {
            $0.isPayloadError = true
        }
    }

    @Test
    func testWritePayloadURL() async throws {
        let testNFCSession = NFCSessionClient { _ in
        } read: {
            return .empty
        }
        let tag = Tag(name: "Test", payload: .url(URL(string: "https://example.com")!))

        let store = TestStore(initialState: TagCreateFeature.State(tag: tag, type: .url)) {
            TagCreateFeature()
        } withDependencies: {
            $0.nfcSession = testNFCSession
        }

        store.exhaustivity = .off

        await store.send(.setPayloadURL("https://example.com"))
        await store.send(.writeButtonTapped)
        await store.receive(\.delegate, .saveTag(tag))
    }
}
