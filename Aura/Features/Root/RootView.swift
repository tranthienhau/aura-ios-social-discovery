import SwiftUI

enum RootTab: String, CaseIterable, Identifiable {
    case map, discover, chat, profile
    var id: String { rawValue }
    var title: String {
        switch self {
        case .map: "Map"; case .discover: "Discover"; case .chat: "Chat"; case .profile: "Profile"
        }
    }
    var icon: String {
        switch self {
        case .map: "map"; case .discover: "safari"; case .chat: "bubble.left"; case .profile: "person"
        }
    }
}

struct RootView: View {
    @Binding var tab: RootTab

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch tab {
                case .map: MapDiscoveryView()
                case .discover: DiscoverView()
                case .chat: ChatListView()
                case .profile: ProfileView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            AuraTabBar(selection: $tab)
        }
        .background(AuraColor.surface.ignoresSafeArea())
    }
}

/// Custom floating tab bar matching the design (amber active pill, warm surface).
struct AuraTabBar: View {
    @Binding var selection: RootTab

    var body: some View {
        HStack {
            ForEach(RootTab.allCases) { t in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { selection = t }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: t.icon)
                            .font(.system(size: 20, weight: selection == t ? .semibold : .regular))
                            .symbolVariant(selection == t ? .fill : .none)
                        Text(t.title).font(AuraFont.labelSm())
                    }
                    .foregroundStyle(selection == t ? AuraColor.primaryDeep : AuraColor.onSurfaceVariant.opacity(0.7))
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("tab_\(t.rawValue)")
            }
        }
        .padding(.top, 12)
        .padding(.horizontal, 8)
        .padding(.bottom, 4)
        .background(
            AuraColor.surface
                .overlay(AuraColor.onSurface.opacity(0.04), alignment: .top)
                .ignoresSafeArea(edges: .bottom)
        )
    }
}
