import Foundation
import Combine

final class DebateViewModel: ObservableObject {
    @Published var topic: String
    @Published var draft = ""
    @Published var currentSpeaker: Participant
    @Published var yegorName: String
    @Published var friendName: String
    @Published private(set) var messages: [ChatMessage]

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

    var messageCountLabel: String {
        "\(messages.filter { !$0.isSystemMessage }.count) hot takes logged"
    }

    init(sessionStore: DebateSessionStore = DebateSessionStore()) {
        self.sessionStore = sessionStore

        if let snapshot = sessionStore.load(), !snapshot.messages.isEmpty {
            topic = snapshot.topic
            currentSpeaker = snapshot.currentSpeaker
            yegorName = snapshot.yegorName
            friendName = snapshot.friendName
            messages = snapshot.messages
        } else {
            topic = Self.defaultTopic
            currentSpeaker = .yegor
            yegorName = Participant.yegor.displayName
            friendName = Participant.friend.displayName
            messages = Self.starterMessages()
            saveSession()
        }
    }

    func name(for participant: Participant) -> String {
        switch participant {
        case .yegor:
            return yegorName
        case .friend:
            return friendName
        }
    }

    func setName(_ name: String, for participant: Participant) {
        let cleanedName = sanitizedName(name, fallback: participant.displayName)

        switch participant {
        case .yegor:
            guard yegorName != cleanedName else { return }
            yegorName = cleanedName
        case .friend:
            guard friendName != cleanedName else { return }
            friendName = cleanedName
        }

        saveSession()
    }

    func sendMessage() {
        let trimmed = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        guard !containsPoliticalContent(trimmed) else {
            messages.append(
                ChatMessage(
                    author: nil,
                    text: "Political detour denied. This stage is reserved for ideas, jokes, and verbal parkour.",
                    timestamp: .now
                )
            )
            draft = ""
            saveSession()
            return
        }

        messages.append(
            ChatMessage(
                author: currentSpeaker,
                text: trimmed,
                timestamp: .now
            )
        )
        draft = ""
        currentSpeaker = currentSpeaker == .yegor ? .friend : .yegor
        saveSession()
    }

    func usePrompt(_ prompt: String) {
        draft = prompt
    }

    func switchSpeaker() {
        currentSpeaker = currentSpeaker == .yegor ? .friend : .yegor
        saveSession()
    }

    func resetConversation() {
        draft = ""
        currentSpeaker = .yegor
        messages = [
            ChatMessage(
                author: nil,
                text: "Fresh round started. The idea graveyard is full, so please invent responsibly.",
                timestamp: .now
            )
        ]
        saveSession()
    }

    private func containsPoliticalContent(_ text: String) -> Bool {
        let lowercased = text.lowercased()
        return politicalKeywords.contains(where: lowercased.contains)
    }

    private func sanitizedName(_ name: String, fallback: String) -> String {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? fallback : String(trimmed.prefix(20))
    }

    private func saveSession() {
        sessionStore.save(
            DebateSessionSnapshot(
                topic: topic,
                currentSpeaker: currentSpeaker,
                yegorName: yegorName,
                friendName: friendName,
                messages: messages
            )
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
