# MatYegorChitChat

A tiny macOS SwiftUI debate app for two friends.

## What it does
- Lets two people share one local conversation thread
- Alternates the active speaker, with a manual `Pass Mic` option
- Starts with playful, non-political prompts
- Blocks obvious political keywords to keep the chat focused on ideas and banter
- Keeps the UI simple so persistence, networking, or AI features can be added later

## Main files
- `MatYegorChitChat/MatYegorChitChatApp.swift` — app entry and desktop window sizing
- `MatYegorChitChat/ContentView.swift` — main chat/debate UI
- `MatYegorChitChat/Participant.swift` — the two chat participants
- `MatYegorChitChat/ChatMessage.swift` — message model
- `MatYegorChitChat/DebateViewModel.swift` — app state and rules

## Run
Open `MatYegorChitChat.xcodeproj` in Xcode and run the `MatYegorChitChat` scheme on macOS.

## Next good upgrades
- Save chat history locally
- Rename the second participant from `Friend`
- Add multiple debate rooms or topics
- Export the best ideas into notes
