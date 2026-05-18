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
            LinearGradient(
                colors: [Color.black, Color(red: 0.08, green: 0.08, blue: 0.14)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                header
                speakerPanel
                promptPanel
                transcriptPanel
                composerPanel
            }
            .padding(24)
        }
        .frame(minWidth: 980, minHeight: 720)
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 10) {
                Label("ChitChat Debate Lab", systemImage: "theatermasks.fill")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("Two humans. One thread. Infinite overconfident ideas. Humor is welcome, politics gets benched, and your chat stays saved on this Mac.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.72))

                HStack(spacing: 10) {
                    CapsuleTag(title: "Topic", value: viewModel.topic, tint: .orange)
                    CapsuleTag(title: "Status", value: viewModel.messageCountLabel, tint: .mint)
                    CapsuleTag(title: "Memory", value: "Local history on", tint: .blue)
                }
            }

            Spacer(minLength: 20)

            Button(role: .destructive) {
                viewModel.resetConversation()
            } label: {
                Label("New Round", systemImage: "arrow.clockwise")
            }
            .buttonStyle(.bordered)
            .tint(.red)
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var speakerPanel: some View {
        HStack(spacing: 16) {
            ForEach(Participant.allCases) { participant in
                SpeakerCard(
                    participant: participant,
                    displayName: viewModel.name(for: participant),
                    isActive: participant == viewModel.currentSpeaker,
                    onCommitName: { newName in
                        viewModel.setName(newName, for: participant)
                    }
                )
            }
        }
    }

    private var promptPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick sparks")
                .font(.headline)
                .foregroundStyle(.white)

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
                                .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
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
                            displayName: message.author.map(viewModel.name(for:))
                        )
                            .id(message.id)
                    }
                }
                .padding(20)
            }
            .background(Color.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
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
                    .foregroundStyle(.white.opacity(0.55))
            }

            Text("Tip: rename either side in the speaker cards. Names and debate history save automatically.")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.55))

            ZStack(alignment: .topLeading) {
                TextEditor(text: $viewModel.draft)
                    .scrollContentBackground(.hidden)
                    .font(.body)
                    .foregroundStyle(.white)
                    .padding(8)
                    .frame(minHeight: 130)
                    .background(Color.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 18, style: .continuous))

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
                    .foregroundStyle(.white.opacity(0.55))

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
        .background(tint.opacity(0.22), in: Capsule())
    }
}

private struct SpeakerCard: View {
    let participant: Participant
    let displayName: String
    let isActive: Bool
    let onCommitName: (String) -> Void

    @State private var draftName: String = ""
    @FocusState private var isEditingName: Bool

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

            VStack(alignment: .leading, spacing: 4) {
                TextField("Name", text: $draftName)
                    .textFieldStyle(.roundedBorder)
                    .focused($isEditingName)
                    .onSubmit(commitName)
                    .onChange(of: isEditingName) { _, editing in
                        if !editing {
                            commitName()
                        }
                    }
                    .onChange(of: displayName) { _, newValue in
                        guard !isEditingName else { return }
                        draftName = newValue
                    }

                Text(isActive ? "Has the mic and questionable confidence" : "Waiting to deliver the next masterpiece")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.62))
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
                .fill(isActive ? participant.accentColor.opacity(0.18) : Color.white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(isActive ? participant.accentColor.opacity(0.9) : Color.white.opacity(0.08), lineWidth: 1)
        )
        .onAppear {
            draftName = displayName
        }
    }

    private var shortLabel: String {
        let trimmed = draftName.trimmingCharacters(in: .whitespacesAndNewlines)
        return String((trimmed.isEmpty ? displayName : trimmed).prefix(1)).uppercased()
    }

    private func commitName() {
        onCommitName(draftName)
    }
}

private struct MessageBubble: View {
    let message: ChatMessage
    let displayName: String?

    var body: some View {
        if let author = message.author {
            HStack(alignment: .top) {
                if author == .friend { Spacer(minLength: 60) }

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Label(displayName ?? author.displayName, systemImage: author.icon)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(author.accentColor)

                        Spacer(minLength: 8)

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
                .frame(maxWidth: 560, alignment: .leading)
                .background(author.accentColor.opacity(0.16), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(author.accentColor.opacity(0.25), lineWidth: 1)
                )

                if author == .yegor { Spacer(minLength: 60) }
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
                    .background(Color.white.opacity(0.06), in: Capsule())
                Spacer()
            }
            .padding(.vertical, 4)
        }
    }
}

#Preview {
    ContentView()
        .frame(width: 1100, height: 760)
}
