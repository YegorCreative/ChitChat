import SwiftUI

enum AppTheme {
    static let backgroundGradient = LinearGradient(
        colors: [
            Color(red: 0.04, green: 0.04, blue: 0.08),
            Color(red: 0.10, green: 0.05, blue: 0.16),
            Color(red: 0.05, green: 0.11, blue: 0.20)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let sidebarGradient = LinearGradient(
        colors: [Color.white.opacity(0.10), Color.white.opacity(0.04)],
        startPoint: .top,
        endPoint: .bottom
    )

    static let panelFill = Color.white.opacity(0.06)
    static let secondaryFill = Color.white.opacity(0.04)
    static let border = Color.white.opacity(0.08)
    static let subtleText = Color.white.opacity(0.65)
    static let strongText = Color.white
    static let gold = Color(red: 0.98, green: 0.76, blue: 0.28)
    static let appSymbol = "bubble.left.and.bubble.right.fill"
}
