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
        let tags = try context.fetch(FetchDescriptor<TagDTO>())
        return tags.map { $0.toModel }
    }

    func save(_ tag: Tag) async throws {
        let dto = TagDTO(from: tag)
        context.insert(dto)
        try context.save()
    }

    func delete(_ tag: Tag) async throws {
        let predicate = #Predicate<TagDTO> { $0.id == tag.id }
        guard let tagToDelete = try context.fetch(FetchDescriptor<TagDTO>(predicate: predicate)).first else {
            return
        }
        context.delete(tagToDelete)
        try context.save()
    }
}

extension DatabaseClient {
    static var live: DatabaseClient  {
        let database = Database(modelType: TagDTO.self)

        return DatabaseClient {
            try await database.getTags()
        } save: { tag in
            try await database.save(tag)
        } delete: { tag in
            try await database.delete(tag)
        }
    }
}

