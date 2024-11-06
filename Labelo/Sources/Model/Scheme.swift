import Foundation
import SwiftData

typealias TagDTO = SchemaV1.TagDTO
typealias HistoryEntryDTO = SchemaV1.HistoryEntryDTO

enum SchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version = .init(1, 0, 0)
    static var models: [any PersistentModel.Type] = [TagDTO.self]

    enum PayloadDTO: Codable {
        case text(String)
        case url(URL)
        case data(Data)

        var toModel: Tag.Payload {
            switch self {
            case .text(let string):
                    .text(string)
            case .url(let url):
                    .url(url)
            case .data(let data):
                    .data(data)
            }
        }

        static func from(model: Tag.Payload) -> SchemaV1.PayloadDTO {
            switch model {
            case .text(let string):
                    .text(string)
            case .url(let url):
                    .url(url)
            case .data(let data):
                    .data(data)
            }
        }
    }

    @Model
    final class TagDTO: Identifiable, Equatable {
        @Attribute(.unique) var id: UUID
        var name: String
        var payload: PayloadDTO

        init(id: UUID = UUID(), name: String, payload: SchemaV1.PayloadDTO) {
            self.id = id
            self.name = name
            self.payload = payload
        }

        init(from model: Tag) {
            self.id = model.id
            self.name = model.name
            self.payload = SchemaV1.PayloadDTO.from(model: model.payload)
        }

        var toModel: Tag {
            Tag(id: id, name: name, payload: payload.toModel)
        }
    }

    @Model
    final class HistoryEntryDTO: Identifiable, Equatable {
        @Attribute(.unique) var id: UUID
        @Relationship(deleteRule: .cascade)
        var tag: TagDTO
        var readAt: Date

        init(id: UUID = UUID(), tag: TagDTO, readAt: Date) {
            self.id = id
            self.tag = tag
            self.readAt = readAt
        }

        init(from model: HistoryEntry) {
            self.id = model.id
            self.tag = SchemaV1.TagDTO(from: model.tag)
            self.readAt = model.readAt
        }

        var toModel: HistoryEntry {
            HistoryEntry(id: self.id, tag: self.tag.toModel, readAt: self.readAt)
        }
    }
}
