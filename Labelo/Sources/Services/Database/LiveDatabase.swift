import Foundation
import SwiftData
import ComposableArchitecture

actor Database {
    private let container: ModelContainer
    private let context: ModelContext

    init(modelType: any PersistentModel.Type) {
        do {
            self.container = try ModelContainer(
                for: modelType,
                configurations: .init(
                    isStoredInMemoryOnly: false
                )
            )
            self.context = ModelContext(container)
        } catch {
            fatalError("Failed to create a model container!")
        }
    }

    func getTags() async throws -> [Tag] {
        let tags = try context.fetch(FetchDescriptor<Tag>())
        return tags
    }

    func save(_ tag: Tag) async throws {
        context.insert(tag)
        try context.save()
    }

    func delete(_ tag: Tag) async throws {
        context.delete(tag)
        try context.save()
    }
}

extension DatabaseClient {
    static var live: DatabaseClient  {
        let database = Database(modelType: Tag.self)

        return DatabaseClient {
            try await database.getTags()
        } save: { tag in
            try await database.save(tag)
        } delete: { tag in
            try await database.delete(tag)
        }
    }
}

