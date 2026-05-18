import Foundation

struct DebateSessionSnapshot: Codable {
    var topic: String
    var currentSpeaker: Participant
    var yegorName: String
    var friendName: String
    var messages: [ChatMessage]
}

struct DebateSessionStore {
    private let defaults: UserDefaults
    private let storageKey = "debate-session-snapshot"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() -> DebateSessionSnapshot? {
        guard let data = defaults.data(forKey: storageKey) else {
            return nil
        }

        do {
            return try JSONDecoder().decode(DebateSessionSnapshot.self, from: data)
        } catch {
            defaults.removeObject(forKey: storageKey)
            return nil
        }
    }

    func save(_ snapshot: DebateSessionSnapshot) {
        do {
            let data = try JSONEncoder().encode(snapshot)
            defaults.set(data, forKey: storageKey)
        } catch {
            assertionFailure("Failed to save debate session: \(error)")
        }
    }
}
