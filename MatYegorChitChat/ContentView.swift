//
//  ContentView.swift
//  MatYegorChitChat
//
//  Created by Yegor Hambaryan on 5/18/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = DebateViewModel()

    var body: some View {
        ZStack {
            AppTheme.backgroundGradient
                .ignoresSafeArea()

            VStack(spacing: 18) {
                header
                speakerPanel

                if let pinnedMessage = viewModel.pinnedMessage {
                    PinnedIdeaCard(
                        message: pinnedMessage,
                        authorName: pinnedMessage.author.map { viewModel.name(for: $0) } ?? "System",
                        onUnpin: {
                            viewModel.togglePinned(message: pinnedMessage)
                        }
                    )
                }

                promptPanel
                transcriptPanel
                composerPanel
            }
            .padding(20)
        }
        .frame(minWidth: 1100, minHeight: 780)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.gold.opacity(0.18))
                            .frame(width: 56, height: 56)

                        Image(systemName: AppTheme.appSymbol)
                            .font(.title2.weight(.bold))
                            .foregroundStyle(AppTheme.gold)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("ChitChat")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.strongText)

                        Text("One shared thread for you and your friend to argue brilliantly, pin the best idea, and keep the history alive.")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.subtleText)
                    }
                }

                Spacer(minLength: 20)

                VStack(alignment: .trailing, spacing: 10) {
                    HStack(spacing: 10) {
                        Button {
                            viewModel.exportConversation()
                        } label: {
                            Label("Export .txt", systemImage: "square.and.arrow.up")
                        }
                        .buttonStyle(.bordered)

                        Button(role: .destructive) {
                            viewModel.resetConversation()
                        } label: {
                            Label("New Round", systemImage: "arrow.clockwise")
                        }
                        .buttonStyle(.bordered)
                        .tint(.red)
                    }

                    Text(viewModel.exportFeedback.isEmpty ? "Saved locally on this Mac." : viewModel.exportFeedback)
                        .font(.caption)
                        .foregroundStyle(AppTheme.subtleText)
                }
            }

            TextField("Debate topic", text: topicBinding)
                .textFieldStyle(.roundedBorder)

            HStack(spacing: 10) {
                CapsuleTag(title: "Topic", value: viewModel.topic, tint: .orange)
                CapsuleTag(title: "Status", value: viewModel.messageCountLabel, tint: .mint)
                CapsuleTag(title: "Pinned", value: viewModel.pinnedMessage == nil ? "none yet" : "best idea armed", tint: .yellow)
            }
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
    }

    private var speakerPanel: some View {
        HStack(spacing: 16) {
            ForEach(Participant.allCases) { participant in
                SpeakerCard(
                    participant: participant,
                    displayName: nameBinding(for: participant),
                    isActive: participant == viewModel.currentSpeaker
                )
            }
        }
    }

    private var promptPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Quick sparks")
                    .font(.headline)
                    .foregroundStyle(.white)

                Spacer()

                Text("One thread, two humans, infinite confidence.")
                    .font(.caption)
                    .foregroundStyle(AppTheme.subtleText)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.quickPrompts, id: \.self) { prompt in
                        Button {
                            viewModel.usePrompt(prompt)
                        } label: {
                            Text(prompt)
                                .font(.subheadline)
                                .multilineTextAlignment(.leading)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 12)
                                .foregroundStyle(.white)
                                .background(AppTheme.secondaryFill, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(AppTheme.border, lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var transcriptPanel: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 14) {
                    ForEach(viewModel.messages) { message in
                        MessageBubble(
                            message: message,
                            displayName: message.author.map(viewModel.name(for:)) ?? "System",
                            isPinned: viewModel.pinnedMessage?.id == message.id,
                            onTogglePinned: message.isSystemMessage ? nil : {
                                viewModel.togglePinned(message: message)
                            }
                        )
                        .id(message.id)
                    }
                }
                .padding(20)
            }
            .background(AppTheme.secondaryFill, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(AppTheme.border, lineWidth: 1)
            )
            .onAppear {
                scrollToLatest(using: proxy)
            }
            .onChange(of: viewModel.messages) { _, _ in
                scrollToLatest(using: proxy)
            }
        }
    }

    private var composerPanel: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label("Now speaking: \(viewModel.name(for: viewModel.currentSpeaker))", systemImage: viewModel.currentSpeaker.icon)
                    .foregroundStyle(viewModel.currentSpeaker.accentColor)
                    .font(.headline)

                Spacer()

                Text("⌘↩ to send")
                    .font(.caption)
                    .foregroundStyle(AppTheme.subtleText)
            }

            Text("Pin the best message with the little pin button, export the debate when it becomes legendary, and let the dark humor behave itself.")
                .font(.caption)
                .foregroundStyle(AppTheme.subtleText)

            ZStack(alignment: .topLeading) {
                TextEditor(text: $viewModel.draft)
                    .scrollContentBackground(.hidden)
                    .font(.body)
                    .foregroundStyle(.white)
                    .padding(8)
                    .frame(minHeight: 130)
                    .background(AppTheme.secondaryFill, in: RoundedRectangle(cornerRadius: 18, style: .continuous))

                if viewModel.draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text("Drop a clever idea, friendly roast, or wildly confident solution to a fake problem…")
                        .foregroundStyle(.white.opacity(0.35))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 18)
                }
            }

            HStack {
                Button {
                    viewModel.switchSpeaker()
                } label: {
                    Label("Pass Mic", systemImage: "person.2.fill")
                }
                .buttonStyle(.bordered)

                Spacer()

                Text("\(viewModel.draft.count) characters")
                    .font(.caption)
                    .foregroundStyle(AppTheme.subtleText)

                Button {
                    viewModel.sendMessage()
                } label: {
                    Label("Send", systemImage: "paperplane.fill")
                        .fontWeight(.semibold)
                }
                .buttonStyle(.borderedProminent)
                .tint(viewModel.currentSpeaker.accentColor)
                .keyboardShortcut(.return, modifiers: [.command])
            }
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var topicBinding: Binding<String> {
        Binding(
            get: { viewModel.topic },
            set: { viewModel.updateTopic($0) }
        )
    }

    private func nameBinding(for participant: Participant) -> Binding<String> {
        Binding(
            get: { viewModel.name(for: participant) },
            set: { viewModel.setName($0, for: participant) }
        )
    }

    private func scrollToLatest(using proxy: ScrollViewProxy) {
        guard let lastID = viewModel.messages.last?.id else { return }
        DispatchQueue.main.async {
            withAnimation(.easeOut(duration: 0.2)) {
                proxy.scrollTo(lastID, anchor: .bottom)
            }
        }
    }
}

private struct CapsuleTag: View {
    let title: String
    let value: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title.uppercased())
                .font(.caption2.weight(.bold))
                .foregroundStyle(.white.opacity(0.55))

            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .lineLimit(2)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(tint.opacity(0.20), in: Capsule())
    }
}

private struct SpeakerCard: View {
    let participant: Participant
    @Binding var displayName: String
    let isActive: Bool

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(participant.accentColor.opacity(0.22))
                    .frame(width: 48, height: 48)

                Text(shortLabel)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 6) {
                TextField("Name", text: $displayName)
                    .textFieldStyle(.roundedBorder)

                Text(isActive ? "Has the mic and suspicious confidence" : "Waiting to deliver the next masterpiece")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.subtleText)
            }

            Spacer()

            if isActive {
                Text("LIVE")
                    .font(.caption.weight(.heavy))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(participant.accentColor, in: Capsule())
                    .foregroundStyle(.black)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(isActive ? participant.accentColor.opacity(0.18) : AppTheme.secondaryFill)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(isActive ? participant.accentColor.opacity(0.9) : AppTheme.border, lineWidth: 1)
        )
    }

    private var shortLabel: String {
        let trimmed = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        return String((trimmed.isEmpty ? participant.displayName : trimmed).prefix(1)).uppercased()
    }
}

private struct PinnedIdeaCard: View {
    let message: ChatMessage
    let authorName: String
    let onUnpin: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: "pin.fill")
                .font(.title3)
                .foregroundStyle(AppTheme.gold)

            VStack(alignment: .leading, spacing: 8) {
                Text("Best idea of the round")
                    .font(.headline)
                    .foregroundStyle(.white)

                Text(message.text)
                    .font(.body)
                    .foregroundStyle(.white)

                Text("Pinned from \(authorName)")
                    .font(.caption)
                    .foregroundStyle(AppTheme.subtleText)
            }

            Spacer()

            Button("Unpin", action: onUnpin)
                .buttonStyle(.bordered)
        }
        .padding(20)
        .background(AppTheme.gold.opacity(0.14), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(AppTheme.gold.opacity(0.35), lineWidth: 1)
        )
    }
}

private struct MessageBubble: View {
    let message: ChatMessage
    let displayName: String
    let isPinned: Bool
    let onTogglePinned: (() -> Void)?

    var body: some View {
        if let author = message.author {
            HStack(alignment: .top) {
                if author == .friend { Spacer(minLength: 80) }

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Label(displayName, systemImage: author.icon)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(author.accentColor)

                        Spacer(minLength: 8)

                        if let onTogglePinned {
                            Button(action: onTogglePinned) {
                                Image(systemName: isPinned ? "pin.fill" : "pin")
                                    .foregroundStyle(isPinned ? AppTheme.gold : .white.opacity(0.55))
                            }
                            .buttonStyle(.plain)
                        }

                        Text(message.timestamp.formatted(date: .omitted, time: .shortened))
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.4))
                    }

                    Text(message.text)
                        .font(.body)
                        .foregroundStyle(.white)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(16)
                .frame(maxWidth: 620, alignment: .leading)
                .background(author.accentColor.opacity(0.16), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(isPinned ? AppTheme.gold.opacity(0.55) : author.accentColor.opacity(0.25), lineWidth: 1)
                )

                if author == .yegor { Spacer(minLength: 80) }
            }
        } else {
            HStack {
                Spacer()
                Text(message.text)
                    .font(.footnote.weight(.medium))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.76))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(AppTheme.secondaryFill, in: Capsule())
                Spacer()
            }
            .padding(.vertical, 4)
        }
    }
}

#Preview {
    ContentView()
        .frame(width: 1180, height: 820)
}
