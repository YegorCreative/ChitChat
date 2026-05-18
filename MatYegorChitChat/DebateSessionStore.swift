import Foundation

private struct LegacyDebateSessionSnapshot: Codable {
    var topic: String
    var currentSpeaker: Participant
    var yegorName: String
    var friendName: String
    var messages: [ChatMessage]
}

struct DebateWorkspaceSnapshot: Codable {
    var rooms: [DebateRoom]
    var selectedRoomID: UUID?
}

struct DebateSessionStore {
    private let defaults: UserDefaults
    private let storageKey = "debate-session-snapshot"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadWorkspace() -> DebateWorkspaceSnapshot? {
        guard let data = defaults.data(forKey: storageKey) else {
            return nil
        }

        do {
            return try JSONDecoder().decode(DebateWorkspaceSnapshot.self, from: data)
        } catch {
            do {
                let legacy = try JSONDecoder().decode(LegacyDebateSessionSnapshot.self, from: data)
                let now = Date()
                let room = DebateRoom(
                    title: "Main Arena",
                    topic: legacy.topic,
                    currentSpeaker: legacy.currentSpeaker,
                    yegorName: legacy.yegorName,
                    friendName: legacy.friendName,
                    messages: legacy.messages,
                    createdAt: now,
                    updatedAt: now
                )
                return DebateWorkspaceSnapshot(rooms: [room], selectedRoomID: room.id)
            } catch {
                defaults.removeObject(forKey: storageKey)
                return nil
            }
        }
    }

    func saveWorkspace(_ snapshot: DebateWorkspaceSnapshot) {
        do {
            let data = try JSONEncoder().encode(snapshot)
            defaults.set(data, forKey: storageKey)
        } catch {
            assertionFailure("Failed to save debate workspace: \(error)")
        }
    }
}
