import Foundation

struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    let author: Participant?
    let text: String
    let timestamp: Date

    var isSystemMessage: Bool {
        author == nil
    }
}
