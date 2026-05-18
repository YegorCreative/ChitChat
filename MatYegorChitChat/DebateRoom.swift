import Foundation

struct DebateRoom: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var topic: String
    var currentSpeaker: Participant
    var yegorName: String
    var friendName: String
    var messages: [ChatMessage]
    var pinnedMessageID: UUID?
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        topic: String,
        currentSpeaker: Participant,
        yegorName: String,
        friendName: String,
        messages: [ChatMessage],
        pinnedMessageID: UUID? = nil,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.title = title
        self.topic = topic
        self.currentSpeaker = currentSpeaker
        self.yegorName = yegorName
        self.friendName = friendName
        self.messages = messages
        self.pinnedMessageID = pinnedMessageID
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    func name(for participant: Participant) -> String {
        switch participant {
        case .yegor:
            return yegorName
        case .friend:
            return friendName
        }
    }

    var pinnedMessage: ChatMessage? {
        guard let pinnedMessageID else { return nil }
        return messages.first(where: { $0.id == pinnedMessageID })
    }

    var debateCountText: String {
        let count = messages.filter { !$0.isSystemMessage }.count
        return "\(count) takes"
    }
}
