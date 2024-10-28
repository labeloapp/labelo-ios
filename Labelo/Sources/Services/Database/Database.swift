import ComposableArchitecture
import SwiftData

@DependencyClient
struct DatabaseClient {
    var getTags: @Sendable () async throws -> [Tag]
    var save: @Sendable ( _ tag: Tag) async throws -> Void
    var delete: @Sendable ( _ tag: Tag) async throws -> Void
}

extension DatabaseClient: DependencyKey {
    static let liveValue = DatabaseClient.live
}

extension DependencyValues {
    var database: DatabaseClient {
        get { self[DatabaseClient.self] }
        set { self[DatabaseClient.self] = newValue }
    }
}

