import Foundation

struct Tag: Identifiable, Equatable {
    let id: String
    let name: String
}

extension Tag {
    static let mocks: [Tag] = [
        Tag(id: "1", name: "Tag 1"),
        Tag(id: "2", name: "Tag 2"),
        Tag(id: "3", name: "Tag 3"),
    ]
}
