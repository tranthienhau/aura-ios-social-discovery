import SwiftUI

struct ChatView: View {
    @Environment(MockBackend.self) private var backend
    @Environment(\.dismiss) private var dismiss
    let conversationID: UUID
    @State private var draft = ""
    @FocusState private var inputFocused: Bool

    private var convo: Conversation? {
        backend.conversations.first { $0.id == conversationID }
    }

    var body: some View {
        VStack(spacing: 0) {
            if let convo {
                header(convo)
                messages(convo)
                inputBar
            }
        }
        .background(AuraColor.surface)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }

    private func header(_ c: Conversation) -> some View {
        HStack(spacing: 12) {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left").font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(AuraColor.onSurface)
            }
            AvatarView(asset: c.avatar, name: c.name, size: 40)
            VStack(alignment: .leading, spacing: 1) {
                Text(c.name).font(.system(size: 16, weight: .semibold)).foregroundStyle(AuraColor.onSurface)
                Text(c.activeNow ? "Active now" : "Offline")
                    .font(AuraFont.labelSm()).foregroundStyle(c.activeNow ? .green : AuraColor.onSurfaceVariant)
            }
            Spacer()
            Button {} label: {
                Label("Meet Up", systemImage: "calendar")
                    .font(AuraFont.labelMd()).foregroundStyle(AuraColor.onPrimary)
                    .padding(.horizontal, 14).padding(.vertical, 9)
                    .background(AuraColor.primary, in: Capsule())
            }
            .buttonStyle(.plain)
            Image(systemName: "gearshape").foregroundStyle(AuraColor.onSurface)
        }
        .padding(.horizontal, 16).padding(.vertical, 10)
        .background(AuraColor.surface.overlay(AuraColor.onSurface.opacity(0.04), alignment: .bottom))
    }

    private func messages(_ c: Conversation) -> some View {
        ScrollViewReader { proxy in
            ScrollView {
                Text("Today")
                    .font(AuraFont.labelSm()).foregroundStyle(AuraColor.onSurfaceVariant)
                    .padding(.horizontal, 12).padding(.vertical, 5)
                    .background(AuraColor.surfaceContainerHigh, in: Capsule())
                    .padding(.vertical, 12)

                LazyVStack(spacing: 10) {
                    ForEach(c.messages) { m in
                        MessageBubble(message: m).id(m.id)
                    }
                    TypingDots().id("typing")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 4)
                }
                .padding(.horizontal, 16)
            }
            .onChange(of: c.messages.count) {
                withAnimation { proxy.scrollTo(c.messages.last?.id, anchor: .bottom) }
            }
        }
    }

    private var inputBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "plus")
                .font(.system(size: 18, weight: .semibold)).foregroundStyle(AuraColor.onSurfaceVariant)
                .frame(width: 40, height: 40)
                .background(AuraColor.surfaceContainerHigh, in: Circle())

            HStack {
                TextField("Type a message...", text: $draft)
                    .focused($inputFocused)
                    .font(AuraFont.bodyMd())
                    .submitLabel(.send)
                    .onSubmit(sendDraft)
                Image(systemName: "face.smiling").foregroundStyle(AuraColor.primary)
            }
            .padding(.horizontal, 16).padding(.vertical, 11)
            .background(AuraColor.surfaceContainerLow, in: Capsule())

            Button(action: sendDraft) {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 17)).foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(AuraColor.primaryDeep, in: Circle())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("sendButton")
        }
        .padding(.horizontal, 16).padding(.vertical, 10)
        .background(AuraColor.surface.overlay(AuraColor.onSurface.opacity(0.04), alignment: .top))
    }

    private func sendDraft() {
        backend.send(draft, to: conversationID)
        draft = ""
    }
}

struct MessageBubble: View {
    let message: ChatMessage
    var body: some View {
        HStack {
            if message.fromMe { Spacer(minLength: 40) }
            VStack(alignment: message.fromMe ? .trailing : .leading, spacing: 4) {
                Text(message.text)
                    .font(AuraFont.bodyMd())
                    .foregroundStyle(message.fromMe ? AuraColor.onSurface : AuraColor.onSurface)
                    .padding(.horizontal, 16).padding(.vertical, 12)
                    .background(
                        message.fromMe ? AnyShapeStyle(AuraColor.primary) : AnyShapeStyle(AuraColor.surfaceContainerHigh),
                        in: RoundedRectangle(cornerRadius: 20, style: .continuous)
                    )
                if message.fromMe {
                    HStack(spacing: 3) {
                        Text(message.time)
                        Image(systemName: "checkmark.circle.fill")
                    }
                    .font(AuraFont.labelSm()).foregroundStyle(AuraColor.onSurfaceVariant)
                }
            }
            if !message.fromMe { Spacer(minLength: 40) }
        }
    }
}

/// Animated three-dot typing indicator (presence / realtime feel).
struct TypingDots: View {
    @State private var phase = 0
    let timer = Timer.publish(every: 0.35, on: .main, in: .common).autoconnect()
    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<3) { i in
                Circle().fill(AuraColor.outlineVariant)
                    .frame(width: 7, height: 7)
                    .opacity(phase == i ? 1 : 0.4)
                    .scaleEffect(phase == i ? 1.2 : 1)
            }
        }
        .padding(.horizontal, 16).padding(.vertical, 12)
        .background(AuraColor.surfaceContainerHigh, in: Capsule())
        .onReceive(timer) { _ in withAnimation(.easeInOut(duration: 0.3)) { phase = (phase + 1) % 3 } }
    }
}
