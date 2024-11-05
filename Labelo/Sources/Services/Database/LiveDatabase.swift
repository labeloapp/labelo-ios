import Foundation
import SwiftData
import ComposableArchitecture

actor Database {
    private let container: ModelContainer
    private let context: ModelContext

    enum Error: Swift.Error {
        case failedToSave
    }

    init() {
        do {
            // Bad, but can't convert array to variadic args yet in Swift :(
            self.container = try ModelContainer(
                for: TagDTO.self, HistoryEntryDTO.self,
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

    func getHistory() async throws -> [HistoryEntry] {
        let sortDescriptior = SortDescriptor<HistoryEntryDTO>(\.readAt, order: .reverse)
        let history = try context.fetch(FetchDescriptor<HistoryEntryDTO>(sortBy: [sortDescriptior]))
        return history.map { $0.toModel }
    }

    func save(_ entry: HistoryEntry) async throws {
        let id = entry.tag.id
        let predicate = #Predicate<TagDTO> { $0.id == id }
        let tagDTO = try context.fetch(FetchDescriptor<TagDTO>(predicate: predicate))

        let dto = HistoryEntryDTO(from: entry)
        dto.tag = tagDTO.first!
        context.insert(dto)
        try context.save()
    }
}

extension DatabaseClient {
    static var live: DatabaseClient  {
        let database = Database()

        return DatabaseClient {
            try await database.getTags()
        } save: { tag in
            try await database.save(tag)
        } delete: { tag in
            try await database.delete(tag)
        } getHistory: {
            try await database.getHistory()
        } saveHistoryEntry: { entry in
            try await database.save(entry)
        }
    }
}

