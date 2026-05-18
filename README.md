# ChitChat

`ChitChat` is a simple macOS desktop app for two friends to chat, debate, throw around ridiculous ideas, and land on the best one without turning the room into a political talk show.

Built with SwiftUI, the current version is intentionally small, local-first, and easy to grow later.

## Current MVP

- One shared local debate thread for two people
- Turn-based chatting with a clear active speaker
- Editable display names for both participants
- Local conversation history that survives app relaunches
- One pinned “best idea” for the current conversation
- Export the conversation to a plain text transcript
- Quick prompt chips to kick off funny debates and idea battles
- A polished desktop-style SwiftUI layout focused on a single conversation
- A playful tone with dark-ish humor in the UI copy
- A lightweight anti-politics guardrail for the shared space
- Simple architecture that is ready for future upgrades if you ever want more structure later

## Screenshots

Screenshots are coming soon.

When you are ready, save app images in `docs/images/` and link them here. A good first screenshot name would be:

- `docs/images/chitchat-main-window.png`

## Project Structure

- `MatYegorChitChat/MatYegorChitChatApp.swift` — app entry point and macOS window sizing
- `MatYegorChitChat/ContentView.swift` — main desktop chat/debate interface
- `MatYegorChitChat/Participant.swift` — participant metadata like name, icon, and accent color
- `MatYegorChitChat/ChatMessage.swift` — shared message model
- `MatYegorChitChat/DebateRoom.swift` — the persisted conversation/session model
- `MatYegorChitChat/DebateViewModel.swift` — conversation state, prompts, pinning, export, and content rules
- `MatYegorChitChat/DebateSessionStore.swift` — local conversation persistence using `UserDefaults`
- `MatYegorChitChat/ChatExportService.swift` — plain text export for the conversation transcript
- `MatYegorChitChat/AppTheme.swift` — reusable colors and styling tokens
- `MatYegorChitChat/Assets.xcassets` — app icons and accent assets

## Getting Started

### Requirements

- macOS
- Xcode with SwiftUI support

### Run in Xcode

1. Open `MatYegorChitChat.xcodeproj`
2. Select the `MatYegorChitChat` scheme
3. Run the macOS app

### Build from Terminal

```bash
cd /path/to/ChitChat
xcodebuild -project 'MatYegorChitChat.xcodeproj' -scheme 'MatYegorChitChat' -configuration Debug -sdk macosx CODE_SIGNING_ALLOWED=NO build
```

## Git Workflow

- `main` stays stable and should reflect code that is safe to show, demo, or ship
- `dev` is the integration branch for day-to-day progress
- New work should branch from `dev`, not from `main`
- Use small focused branches with clear names:
  - `feature/custom-names`
  - `feature/local-chat-history`
  - `fix/message-scroll`
  - `release/0.1.0`
- Merge flow should usually look like this:
  - `feature/*` -> `dev`
  - `fix/*` -> `dev`
  - `release/*` -> `main` and back into `dev`

For the full branch workflow and example commands, see [`CONTRIBUTING.md`](CONTRIBUTING.md).

## Good Next Steps

- Add simple message search
- Add optional conversation archive/history snapshots
- Add richer pinned idea summaries
- Add real screenshots and a polished app icon
