import Foundation
import Combine

final class DebateViewModel: ObservableObject {
    @Published var draft = ""
    @Published private(set) var session: DebateRoom
    @Published var exportFeedback = ""

    let quickPrompts = [
        "Pitch a ridiculous startup that somehow helps everyone.",
        "What daily problem deserves a hilariously overengineered solution?",
        "Defend your idea like it owes you rent.",
        "What invention would save mornings from becoming tiny tragedies?"
    ]

    private let politicalKeywords = [
        "politics", "political", "election", "government", "president", "senate",
        "congress", "parliament", "minister", "democrat", "republican", "campaign"
    ]

    private let sessionStore: DebateSessionStore
    private let exportService: ChatExportService

    var messages: [ChatMessage] {
        session.messages
    }

    var topic: String {
        session.topic
    }

    var currentSpeaker: Participant {
        session.currentSpeaker
    }

    var pinnedMessage: ChatMessage? {
        session.pinnedMessage
    }

    var messageCountLabel: String {
        "\(messages.filter { !$0.isSystemMessage }.count) hot takes logged"
    }

    init(
        sessionStore: DebateSessionStore = DebateSessionStore(),
        exportService: ChatExportService = ChatExportService()
    ) {
        self.sessionStore = sessionStore
        self.exportService = exportService

        session = sessionStore.loadSession() ?? Self.defaultSession()
        saveSession()
    }

    func updateTopic(_ topic: String) {
        updateSession { session in
            session.topic = sanitizedText(topic, fallback: Self.defaultTopic, maxLength: 100)
        }
    }

    func name(for participant: Participant) -> String {
        session.name(for: participant)
    }

    func setName(_ name: String, for participant: Participant) {
        updateSession { session in
            let cleanedName = sanitizedText(name, fallback: participant.displayName, maxLength: 20)

            switch participant {
            case .yegor:
                session.yegorName = cleanedName
            case .friend:
                session.friendName = cleanedName
            }
        }
    }

    func sendMessage() {
        let trimmed = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        guard !containsPoliticalContent(trimmed) else {
            appendSystemMessage("Political detour denied. This stage is reserved for ideas, jokes, and verbal parkour.")
            draft = ""
            return
        }

        updateSession { session in
            session.messages.append(
                ChatMessage(
                    author: session.currentSpeaker,
                    text: trimmed,
                    timestamp: .now
                )
            )
            session.currentSpeaker = session.currentSpeaker.opponent
        }
        draft = ""
    }

    func usePrompt(_ prompt: String) {
        draft = prompt
    }

    func switchSpeaker() {
        updateSession { session in
            session.currentSpeaker = session.currentSpeaker.opponent
        }
    }

    func togglePinned(message: ChatMessage) {
        guard !message.isSystemMessage else { return }
        updateSession { session in
            session.pinnedMessageID = session.pinnedMessageID == message.id ? nil : message.id
        }
    }

    func resetConversation() {
        draft = ""
        updateSession { session in
            session.currentSpeaker = .yegor
            session.messages = [
                ChatMessage(
                    author: nil,
                    text: "Fresh round started. The idea graveyard is full, so please invent responsibly.",
                    timestamp: .now
                )
            ]
            session.pinnedMessageID = nil
        }
    }

    func exportConversation() {
        do {
            if let url = try exportService.export(session: session) {
                exportFeedback = "Exported \(url.lastPathComponent)"
            } else {
                exportFeedback = "Export cancelled. The words remain safely trapped here."
            }
        } catch {
            exportFeedback = "Export failed: \(error.localizedDescription)"
        }
    }

    private func containsPoliticalContent(_ text: String) -> Bool {
        let lowercased = text.lowercased()
        return politicalKeywords.contains(where: lowercased.contains)
    }

    private func appendSystemMessage(_ text: String) {
        updateSession { session in
            session.messages.append(
                ChatMessage(
                    author: nil,
                    text: text,
                    timestamp: .now
                )
            )
        }
    }

    private func updateSession(_ mutation: (inout DebateRoom) -> Void) {
        mutation(&session)
        session.updatedAt = .now
        saveSession()
    }

    private func sanitizedText(_ value: String, fallback: String, maxLength: Int) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        let capped = String(trimmed.prefix(maxLength))
        return capped.isEmpty ? fallback : capped
    }

    private func saveSession() {
        sessionStore.saveSession(session)
    }

    private static func defaultSession() -> DebateRoom {
        let now = Date()
        return DebateRoom(
            title: "Main Debate",
            topic: defaultTopic,
            currentSpeaker: .yegor,
            yegorName: Participant.yegor.displayName,
            friendName: Participant.friend.displayName,
            messages: starterMessages(),
            createdAt: now,
            updatedAt: now
        )
    }

    private static let defaultTopic = "What absurdly useful invention should humanity build next?"

    private static func starterMessages() -> [ChatMessage] {
        [
            ChatMessage(
                author: nil,
                text: "Welcome to ChitChat: a tiny arena for big ideas, chaotic genius, and zero political speeches.",
                timestamp: .now
            ),
            ChatMessage(
                author: .yegor,
                text: "Opening statement: I want a mug that detects when coffee is emotionally unavailable.",
                timestamp: .now
            ),
            ChatMessage(
                author: .friend,
                text: "Counterpoint: smart socks that warn you when your outfit is one bad decision away from folklore.",
                timestamp: .now
            ),
            ChatMessage(
                author: nil,
                text: "House rules: be funny, be honest, be kind-ish, and keep politics outside like muddy shoes.",
                timestamp: .now
            )
        ]
    }
}
