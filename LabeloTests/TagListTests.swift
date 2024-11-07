import Foundation
import ComposableArchitecture
import Testing

@testable import Labelo

@Suite("Tag List Tests")
@MainActor
struct TagListTests {
    @Test
    func testAddButtonTapped() async throws {
        let uuid = UUID()
        let store = TestStore(initialState: TagListFeature.State()) {
            TagListFeature()
        } withDependencies: {
            $0.uuid = .constant(uuid)
        }

        await store.send(.addButtonTapped) {
            $0.$createTag = PresentationState(wrappedValue: TagCreateFeature.State(tag: .init(id: uuid, name: "", payload: .text(""))))
        }
    }

    @Test
    func testGetTags() async throws {
        let tag = Tag(name: "test", payload: .text("test"))

        let testDatabase: DatabaseClient = .init {
            [tag]
        } save: {
            _ in
        } delete: {
            _ in
        } getHistory: {
            return []
        } saveHistoryEntry: {
            _ in
        }

        let store = TestStore(initialState: TagListFeature.State()) {
            TagListFeature()
        } withDependencies: {
            $0.database = testDatabase
        }

        await store.send(.getTags)
        await store.receive(\.tagResponse, [tag]) {
            $0.tags = [tag]
        }
    }

    @Test
    func testSaveTags() async throws {
        let tag = Tag(name: "test", payload: .text("test"))

        let testDatabase: DatabaseClient = .init {
            [tag]
        } save: {
            _ in
        } delete: {
            _ in
        } getHistory: {
            return []
        } saveHistoryEntry: {
            _ in
        }

        let uuid = UUID()

        let store = TestStore(initialState: TagListFeature.State()) {
            TagListFeature()
        } withDependencies: {
            $0.database = testDatabase
            $0.uuid = .constant(uuid)
        }
        await store.send(\.addButtonTapped) {
            $0.createTag = TagCreateFeature.State(tag: .init(id: uuid, name: "", payload: .text("")))
        }
        await store.send(.createTag(.presented(.delegate(.saveTag(tag))))) {
            $0.createTag = nil
        }
        await store.receive(\.getTags)
        await store.receive(\.tagResponse, [tag]) {
            $0.tags = [tag]
        }
    }

    @Test
    func testCreaTagDismissed() async throws {
        let tag = Tag(name: "test", payload: .text("test"))

        let testDatabase: DatabaseClient = .init {
            [tag]
        } save: {
            _ in
        } delete: {
            _ in
        } getHistory: {
            return []
        } saveHistoryEntry: {
            _ in
        }

        let uuid = UUID()
        let store = TestStore(initialState: TagListFeature.State()) {
            TagListFeature()
        } withDependencies: {
            $0.database = testDatabase
            $0.uuid = .constant(uuid)
        }
        await store.send(\.addButtonTapped) {
            $0.createTag = TagCreateFeature.State(tag: .init(id: uuid, name: "", payload: .text("")))
        }
        await store.send(.createTag(.presented(.delegate(.cancel)))) {
            $0.createTag = nil
        }
    }

    @Test
    func testDeleteTag() async throws {
        let tag = Tag(name: "test", payload: .text("test"))

        let testDatabase: DatabaseClient = .init {
            []
        } save: {
            _ in
        } delete: {
            _ in
        } getHistory: {
            return []
        } saveHistoryEntry: {
            _ in
        }

        let store = TestStore(initialState: TagListFeature.State(tags: [tag])) {
            TagListFeature()
        } withDependencies: {
            $0.database = testDatabase
        }

        await store.send(.delete(tag))
        await store.receive(\.getTags)
        await store.receive(\.tagResponse, []) {
            $0.tags = []
        }
    }

    @Test func testDidTapReadButton() async throws {
        let tag = Tag(name: "test", payload: .text("test"))

        let testDatabase: DatabaseClient = .init {
            [tag]
        } save: {
            _ in
        } delete: {
            _ in
        } getHistory: {
            return []
        } saveHistoryEntry: {
            _ in
        }

        let testNFCSession: NFCSessionClient = .init { _ in
        } read: {
            return .tag(tag)
        }

        let store = TestStore(initialState: TagListFeature.State()) {
            TagListFeature()
        } withDependencies: {
            $0.database = testDatabase
            $0.nfcSession = testNFCSession
        }

        await store.send(.didTapReadButton)
        await store.receive(\.didRead, NFCSessionClient.ReadResult.tag(tag)) {
            $0.readResult = .init(result: .tag(tag))
        }
    }
}
