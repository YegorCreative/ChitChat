import Foundation
import Combine

final class DebateViewModel: ObservableObject {
    @Published var topic = "What absurdly useful invention should humanity build next?"
    @Published var draft = ""
    @Published var currentSpeaker: Participant = .yegor
    @Published private(set) var messages: [ChatMessage] = [
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

    var messageCountLabel: String {
        "\(messages.filter { !$0.isSystemMessage }.count) hot takes logged"
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
    }

    func usePrompt(_ prompt: String) {
        draft = prompt
    }

    func switchSpeaker() {
        currentSpeaker = currentSpeaker == .yegor ? .friend : .yegor
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
    }

    private func containsPoliticalContent(_ text: String) -> Bool {
        let lowercased = text.lowercased()
        return politicalKeywords.contains(where: lowercased.contains)
    }
}
