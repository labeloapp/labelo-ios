import Foundation
import ComposableArchitecture

struct Tag: Codable, Identifiable, Equatable {
    enum Payload: Codable, Equatable, Hashable {
        case text(String)
        case url(URL)
        case data(Data)

        var name: String {
            switch self {
            case .text: return "text"
            case .url: return "URL"
            case .data: return "data"
            }
        }
    }

    let id: UUID
    var name: String
    var payload: Payload

    init(id: UUID = UUID(), name: String, payload: Payload) {
        self.id = id
        self.name = name
        self.payload = payload
    }
}

extension Tag {
    var payloadType: String {
        payload.name
    }
}

extension Tag {
    static let mocks: [Tag] = [
        Tag(name: "Tag 1", payload: .text("Hello World")),
        Tag(name: "Tag 2", payload: .url(URL(string: "https://example.com")!)),
        Tag(name: "Tag 3", payload: .text("Test"))
    ]

    static let empty = Tag(name: "", payload: .text(""))
}

