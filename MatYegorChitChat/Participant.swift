import SwiftUI

enum Participant: String, CaseIterable, Identifiable, Codable, Hashable {
    case yegor
    case friend

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .yegor:
            return "Yegor"
        case .friend:
            return "Friend"
        }
    }

    var shortLabel: String {
        switch self {
        case .yegor:
            return "Y"
        case .friend:
            return "F"
        }
    }

    var accentColor: Color {
        switch self {
        case .yegor:
            return .cyan
        case .friend:
            return .purple
        }
    }

    var icon: String {
        switch self {
        case .yegor:
            return "bolt.fill"
        case .friend:
            return "sparkles"
        }
    }

    var opponent: Participant {
        switch self {
        case .yegor:
            return .friend
        case .friend:
            return .yegor
        }
    }
}
