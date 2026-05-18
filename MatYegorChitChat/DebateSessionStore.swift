import Foundation

private struct LegacyDebateSessionSnapshot: Codable {
    var topic: String
    var currentSpeaker: Participant
    var yegorName: String
    var friendName: String
    var messages: [ChatMessage]
}

private struct LegacyDebateWorkspaceSnapshot: Codable {
    var rooms: [DebateRoom]
    var selectedRoomID: UUID?
}

struct DebateSessionSnapshot: Codable {
    var session: DebateRoom
}

struct DebateSessionStore {
    private let defaults: UserDefaults
    private let storageKey = "debate-session-snapshot"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadSession() -> DebateRoom? {
        guard let data = defaults.data(forKey: storageKey) else {
            return nil
        }

        do {
            return try JSONDecoder().decode(DebateSessionSnapshot.self, from: data).session
        } catch {
            do {
                let workspace = try JSONDecoder().decode(LegacyDebateWorkspaceSnapshot.self, from: data)
                if let selectedID = workspace.selectedRoomID,
                   let selectedRoom = workspace.rooms.first(where: { $0.id == selectedID }) {
                    return selectedRoom
                }
                if let firstRoom = workspace.rooms.first {
                    return firstRoom
                }
            } catch {
            }

            do {
                let legacy = try JSONDecoder().decode(LegacyDebateSessionSnapshot.self, from: data)
                let now = Date()
                return DebateRoom(
                    title: "Main Debate",
                    topic: legacy.topic,
                    currentSpeaker: legacy.currentSpeaker,
                    yegorName: legacy.yegorName,
                    friendName: legacy.friendName,
                    messages: legacy.messages,
                    createdAt: now,
                    updatedAt: now
                )
            } catch {
                defaults.removeObject(forKey: storageKey)
                return nil
            }
        }
    }

    func saveSession(_ session: DebateRoom) {
        do {
            let data = try JSONEncoder().encode(DebateSessionSnapshot(session: session))
            defaults.set(data, forKey: storageKey)
        } catch {
            assertionFailure("Failed to save debate session: \(error)")
        }
    }
}
