import SwiftUI

struct ChatListView: View {
    @Environment(MockBackend.self) private var backend
    @State private var path: [UUID] = []

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                LazyVStack(spacing: 4) {
                    ForEach(backend.conversations) { c in
                        NavigationLink(value: c.id) {
                            ChatRow(conversation: c)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 90)
            }
            .background(AuraColor.surface)
            .navigationTitle("Messages")
            .navigationDestination(for: UUID.self) { id in
                if let c = backend.conversations.first(where: { $0.id == id }) {
                    ChatView(conversationID: c.id)
                }
            }
        }
        .tint(AuraColor.primaryDeep)
        .onAppear {
            if ProcessInfo.processInfo.arguments.contains("-openChat"),
               let first = backend.conversations.first, path.isEmpty {
                path = [first.id]
            }
        }
    }
}

struct ChatRow: View {
    let conversation: Conversation
    var body: some View {
        HStack(spacing: 12) {
            AvatarView(asset: conversation.avatar, name: conversation.name, size: 52)
                .overlay(alignment: .bottomTrailing) {
                    if conversation.activeNow {
                        Circle().fill(Color.green).frame(width: 13, height: 13)
                            .overlay(Circle().stroke(AuraColor.surface, lineWidth: 2))
                    }
                }
            VStack(alignment: .leading, spacing: 3) {
                Text(conversation.name).font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AuraColor.onSurface)
                Text(conversation.lastMessage).font(AuraFont.bodyMd())
                    .foregroundStyle(AuraColor.onSurfaceVariant).lineLimit(1)
            }
            Spacer()
            Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold))
                .foregroundStyle(AuraColor.outlineVariant)
        }
        .padding(14)
        .background(AuraColor.containerLowest, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .auraCardShadow()
        .padding(.vertical, 4)
    }
}
