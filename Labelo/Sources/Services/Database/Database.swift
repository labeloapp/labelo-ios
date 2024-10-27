import ComposableArchitecture
import SwiftData

@DependencyClient
struct Database {
    var getTags: @Sendable () async throws -> [Tag]
    var save: @Sendable ( _ tag: Tag) async throws -> Void
    var delete: @Sendable ( _ tag: Tag) async throws -> Void
}

extension Database {
    static let live: Database = .init {
        print("get tag")
        return Tag.mocks
    } save: { tag in
        print("save tag")
    } delete: { tag in
        print("delete tag")
    }
}

extension Database: DependencyKey {
    static let liveValue = Database.live
}

extension DependencyValues {
    var database: Database {
        get { self[Database.self] }
        set { self[Database.self] = newValue }
    }
}

