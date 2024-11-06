import Foundation

struct HistoryEntry: Identifiable, Equatable {
    let id: UUID
    let tag: Tag
    let readAt: Date

    init(id: UUID = UUID(), tag: Tag, readAt: Date) {
        self.id = id
        self.tag = tag
        self.readAt = readAt
    }
}
