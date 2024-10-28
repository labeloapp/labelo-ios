import Foundation
import SwiftData

typealias Tag = SchemaV1.Tag

enum SchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version = .init(1, 0, 0)
    static var models: [any PersistentModel.Type] = [Tag.self]

    @Model
    final class Tag: Identifiable, Equatable {
        @Attribute(.unique) var id: UUID
        var name: String

        init(id: UUID = UUID(), name: String) {
            self.id = id
            self.name = name
        }

        static let mocks: [Tag] = [
            Tag(name: "Tag 1"),
            Tag(name: "Tag 2"),
            Tag(name: "Tag 3"),
        ]
    }
}
