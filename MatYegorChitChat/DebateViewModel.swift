import Foundation
import Combine

final class DebateViewModel: ObservableObject {
    @Published var draft = ""
    @Published private(set) var rooms: [DebateRoom]
    @Published var selectedRoomID: UUID
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

    var selectedRoom: DebateRoom? {
        rooms.first(where: { $0.id == selectedRoomID })
    }

    var selectedMessages: [ChatMessage] {
        selectedRoom?.messages ?? []
    }

    var currentSpeaker: Participant {
        selectedRoom?.currentSpeaker ?? .yegor
    }

    var pinnedMessage: ChatMessage? {
        selectedRoom?.pinnedMessage
    }

    var roomCountLabel: String {
        "\(rooms.count) rooms live"
    }

    var messageCountLabel: String {
        "\(selectedMessages.filter { !$0.isSystemMessage }.count) hot takes logged"
    }

    init(
        sessionStore: DebateSessionStore = DebateSessionStore(),
        exportService: ChatExportService = ChatExportService()
    ) {
        self.sessionStore = sessionStore
        self.exportService = exportService

        let snapshot = sessionStore.loadWorkspace() ?? Self.defaultWorkspace()
        let safeRooms = snapshot.rooms.isEmpty ? Self.defaultWorkspace().rooms : snapshot.rooms
        rooms = safeRooms
        selectedRoomID = snapshot.selectedRoomID ?? safeRooms.first?.id ?? safeRooms[0].id

        if rooms.contains(where: { $0.id == selectedRoomID }) == false, let firstRoom = rooms.first {
            selectedRoomID = firstRoom.id
        }

        saveWorkspace()
    }

    func selectRoom(id: UUID) {
        guard rooms.contains(where: { $0.id == id }) else { return }
        selectedRoomID = id
        exportFeedback = ""
        saveWorkspace()
    }

    func createRoom() {
        let roomNumber = rooms.count + 1
        let room = Self.makeRoom(
            title: "Idea Arena \(roomNumber)",
            topic: quickPrompts[(roomNumber - 1) % quickPrompts.count]
        )
        rooms.insert(room, at: 0)
        selectedRoomID = room.id
        draft = ""
        exportFeedback = "Fresh room created. Time to invent irresponsibly."
        saveWorkspace()
    }

    func updateSelectedRoomTitle(_ title: String) {
        updateSelectedRoom { room in
            room.title = sanitizedText(title, fallback: "Idea Arena", maxLength: 40)
        }
    }

    func updateSelectedTopic(_ topic: String) {
        updateSelectedRoom { room in
            room.topic = sanitizedText(topic, fallback: Self.defaultTopic, maxLength: 100)
        }
    }

    func name(for participant: Participant) -> String {
        guard let selectedRoom else { return participant.displayName }
        return selectedRoom.name(for: participant)
    }

    func name(for participant: Participant, in room: DebateRoom) -> String {
        room.name(for: participant)
    }

    func setName(_ name: String, for participant: Participant) {
        updateSelectedRoom { room in
            let cleanedName = sanitizedText(name, fallback: participant.displayName, maxLength: 20)

            switch participant {
            case .yegor:
                room.yegorName = cleanedName
            case .friend:
                room.friendName = cleanedName
            }
        }
    }

    func subtitle(for room: DebateRoom) -> String {
        room.topic
    }

    func roomMeta(for room: DebateRoom) -> String {
        let pinFlag = room.pinnedMessage == nil ? "" : " • pinned"
        return "\(room.debateCountText)\(pinFlag)"
    }

    func sendMessage() {
        let trimmed = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        guard !containsPoliticalContent(trimmed) else {
            appendSystemMessage("Political detour denied. This stage is reserved for ideas, jokes, and verbal parkour.")
            draft = ""
            return
        }

        updateSelectedRoom { room in
            room.messages.append(
                ChatMessage(
                    author: room.currentSpeaker,
                    text: trimmed,
                    timestamp: .now
                )
            )
            room.currentSpeaker = room.currentSpeaker.opponent
        }
        draft = ""
    }

    func usePrompt(_ prompt: String) {
        draft = prompt
    }

    func switchSpeaker() {
        updateSelectedRoom { room in
            room.currentSpeaker = room.currentSpeaker.opponent
        }
    }

    func togglePinned(message: ChatMessage) {
        guard !message.isSystemMessage else { return }
        updateSelectedRoom { room in
            room.pinnedMessageID = room.pinnedMessageID == message.id ? nil : message.id
        }
    }

    func resetConversation() {
        draft = ""
        updateSelectedRoom { room in
            room.currentSpeaker = .yegor
            room.messages = [
                ChatMessage(
                    author: nil,
                    text: "Fresh round started in \(room.title). The idea graveyard is full, so please invent responsibly.",
                    timestamp: .now
                )
            ]
            room.pinnedMessageID = nil
        }
    }

    func exportSelectedRoom() {
        guard let selectedRoom else { return }

        do {
            if let url = try exportService.export(room: selectedRoom) {
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
        updateSelectedRoom { room in
            room.messages.append(
                ChatMessage(
                    author: nil,
                    text: text,
                    timestamp: .now
                )
            )
        }
    }

    private func updateSelectedRoom(_ mutation: (inout DebateRoom) -> Void) {
        guard let index = rooms.firstIndex(where: { $0.id == selectedRoomID }) else { return }
        mutation(&rooms[index])
        rooms[index].updatedAt = .now
        saveWorkspace()
    }

    private func sanitizedText(_ value: String, fallback: String, maxLength: Int) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        let capped = String(trimmed.prefix(maxLength))
        return capped.isEmpty ? fallback : capped
    }

    private func saveWorkspace() {
        sessionStore.saveWorkspace(
            DebateWorkspaceSnapshot(
                rooms: rooms,
                selectedRoomID: selectedRoomID
            )
        )
    }

    private static func defaultWorkspace() -> DebateWorkspaceSnapshot {
        let room = makeRoom(title: "Main Arena", topic: defaultTopic)
        return DebateWorkspaceSnapshot(rooms: [room], selectedRoomID: room.id)
    }

    private static func makeRoom(title: String, topic: String) -> DebateRoom {
        let now = Date()
        return DebateRoom(
            title: title,
            topic: topic,
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
