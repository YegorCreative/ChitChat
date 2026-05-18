import AppKit
import Foundation
import UniformTypeIdentifiers

struct ChatExportService {
    func export(session: DebateRoom) throws -> URL? {
        let panel = NSSavePanel()
        panel.title = "Export Conversation"
        panel.message = "Save this debate as a plain text transcript."
        panel.allowedContentTypes = [.plainText]
        panel.canCreateDirectories = true
        panel.nameFieldStringValue = suggestedFileName(for: session)

        guard panel.runModal() == .OK, let url = panel.url else {
            return nil
        }

        try formattedTranscript(for: session).write(to: url, atomically: true, encoding: .utf8)
        return url
    }

    func formattedTranscript(for session: DebateRoom) -> String {
        var lines = [String]()
        lines.append("ChitChat Export")
        lines.append("Conversation: \(session.title)")
        lines.append("Topic: \(session.topic)")
        lines.append("Participants: \(session.yegorName) vs \(session.friendName)")
        lines.append("Created: \(Self.longDateFormatter.string(from: session.createdAt))")
        lines.append("Last updated: \(Self.longDateFormatter.string(from: session.updatedAt))")

        if let pinnedMessage = session.pinnedMessage, let author = pinnedMessage.author {
            lines.append("Pinned idea: \(session.name(for: author)) — \(pinnedMessage.text)")
        } else {
            lines.append("Pinned idea: none")
        }

        lines.append("")
        lines.append("Transcript")
        lines.append(String(repeating: "=", count: 48))

        for message in session.messages {
            let timestamp = Self.shortDateFormatter.string(from: message.timestamp)
            if let author = message.author {
                let pinnedSuffix = session.pinnedMessageID == message.id ? " [PINNED]" : ""
                lines.append("[\(timestamp)] \(session.name(for: author)):\(pinnedSuffix) \(message.text)")
            } else {
                lines.append("[\(timestamp)] System: \(message.text)")
            }
        }

        lines.append("")
        lines.append("Exported from ChitChat on \(Self.longDateFormatter.string(from: .now))")
        return lines.joined(separator: "\n")
    }

    private func suggestedFileName(for session: DebateRoom) -> String {
        let source = session.topic.isEmpty ? session.title : session.topic
        let safeTitle = source
            .lowercased()
            .replacingOccurrences(of: "[^a-z0-9]+", with: "-", options: .regularExpression)
            .trimmingCharacters(in: CharacterSet(charactersIn: "-"))
        return safeTitle.isEmpty ? "chitchat-export.txt" : "\(safeTitle).txt"
    }

    private static let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()

    private static let longDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}
