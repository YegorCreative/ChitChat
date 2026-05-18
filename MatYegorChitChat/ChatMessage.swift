import Foundation

struct ChatMessage: Identifiable, Equatable, Codable {
    let id: UUID
    let author: Participant?
    let text: String
    let timestamp: Date

    init(id: UUID = UUID(), author: Participant?, text: String, timestamp: Date) {
        self.id = id
        self.author = author
        self.text = text
        self.timestamp = timestamp
    }

    var isSystemMessage: Bool {
        author == nil
    }
}
