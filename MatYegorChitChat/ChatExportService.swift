import AppKit
import Foundation
import UniformTypeIdentifiers

struct ChatExportService {
    func export(room: DebateRoom) throws -> URL? {
        let panel = NSSavePanel()
        panel.title = "Export Debate"
        panel.message = "Save this room as a plain text transcript."
        panel.allowedContentTypes = [.plainText]
        panel.canCreateDirectories = true
        panel.nameFieldStringValue = suggestedFileName(for: room)

        guard panel.runModal() == .OK, let url = panel.url else {
            return nil
        }

        try formattedTranscript(for: room).write(to: url, atomically: true, encoding: .utf8)
        return url
    }

    func formattedTranscript(for room: DebateRoom) -> String {
        var lines = [String]()
        lines.append("ChitChat Export")
        lines.append("Room: \(room.title)")
        lines.append("Topic: \(room.topic)")
        lines.append("Participants: \(room.yegorName) vs \(room.friendName)")
        lines.append("Created: \(Self.longDateFormatter.string(from: room.createdAt))")
        lines.append("Last updated: \(Self.longDateFormatter.string(from: room.updatedAt))")

        if let pinnedMessage = room.pinnedMessage, let author = pinnedMessage.author {
            lines.append("Pinned idea: \(room.name(for: author)) — \(pinnedMessage.text)")
        } else {
            lines.append("Pinned idea: none")
        }

        lines.append("")
        lines.append("Transcript")
        lines.append(String(repeating: "=", count: 48))

        for message in room.messages {
            let timestamp = Self.shortDateFormatter.string(from: message.timestamp)
            if let author = message.author {
                let pinnedSuffix = room.pinnedMessageID == message.id ? " [PINNED]" : ""
                lines.append("[\(timestamp)] \(room.name(for: author)):\(pinnedSuffix) \(message.text)")
            } else {
                lines.append("[\(timestamp)] System: \(message.text)")
            }
        }

        lines.append("")
        lines.append("Exported from ChitChat on \(Self.longDateFormatter.string(from: .now))")
        return lines.joined(separator: "\n")
    }

    private func suggestedFileName(for room: DebateRoom) -> String {
        let safeTitle = room.title
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
