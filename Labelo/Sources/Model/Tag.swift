import Foundation
import SwiftData

@Model
final class Tag: Identifiable, Equatable {
    let id: String
    let name: String

    init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}

extension Tag {
    static let mocks: [Tag] = [
        Tag(id: "1", name: "Tag 1"),
        Tag(id: "2", name: "Tag 2"),
        Tag(id: "3", name: "Tag 3"),
    ]
}
