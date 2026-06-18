import SwiftUI

struct DiscoverView: View {
    @Environment(MockBackend.self) private var backend

    var body: some View {
        @Bindable var backend = backend
        VStack(spacing: 0) {
            header
            filterTabs
                .padding(.horizontal, 20).padding(.top, 4).padding(.bottom, 12)

            ZStack {
                ForEach(Array(backend.visibleFeed.prefix(3).enumerated()), id: \.element.id) { idx, profile in
                    SwipeCard(profile: profile, isTop: idx == 0) { backend.consumeTop() }
                        .scaleEffect(1 - CGFloat(idx) * 0.04)
                        .offset(y: CGFloat(idx) * 14)
                        .zIndex(Double(3 - idx))
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 8)

            Text("Swipe for more")
                .font(AuraFont.labelMd()).foregroundStyle(AuraColor.onSurfaceVariant)
            Image(systemName: "chevron.compact.down")
                .foregroundStyle(AuraColor.onSurfaceVariant.opacity(0.6))
                .padding(.top, 2)

            Spacer(minLength: 80)
        }
        .background(AuraColor.surface)
    }

    private var header: some View {
        HStack {
            AvatarView(asset: "p_me", name: "You", size: 36)
            Text("Aura").font(AuraFont.headlineMd()).foregroundStyle(AuraColor.primaryDeep)
            Spacer()
            Image(systemName: "gearshape")
                .font(.system(size: 20)).foregroundStyle(AuraColor.onSurface)
        }
        .padding(.horizontal, 20).padding(.vertical, 8)
    }

    private var filterTabs: some View {
        @Bindable var backend = backend
        return HStack(spacing: 8) {
            ForEach(DiscoverFilter.allCases) { f in
                let active = backend.filter == f
                Text(f.rawValue)
                    .font(AuraFont.labelMd())
                    .foregroundStyle(active ? AuraColor.onPrimary : AuraColor.onSurfaceVariant)
                    .padding(.horizontal, 18).padding(.vertical, 9)
                    .background(active ? AuraColor.primary : AuraColor.surfaceContainerHigh,
                                in: Capsule())
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) { backend.filter = f }
                    }
            }
            Spacer()
        }
    }
}

/// A single draggable discovery card with rotation + like/pass overlays.
struct SwipeCard: View {
    let profile: Profile
    let isTop: Bool
    var onConsume: () -> Void

    @State private var drag: CGSize = .zero
    @State private var liked = false

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottomLeading) {
                PhotoView(asset: profile.photo, seed: profile.name)
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()

                likePassStamp

                VStack(alignment: .leading, spacing: 10) {
                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(profile.name), \(profile.age)")
                                .font(AuraFont.headlineLg()).foregroundStyle(.white)
                            Label("Valencia · \(Int(profile.distanceKm))km away", systemImage: "mappin.and.ellipse")
                                .font(AuraFont.labelMd()).foregroundStyle(.white.opacity(0.9))
                        }
                        Spacer()
                        Button {
                            liked = true
                            withAnimation(.easeIn(duration: 0.25)) { drag = CGSize(width: 600, height: -60) }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { onConsume() }
                        } label: {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundStyle(AuraColor.secondary)
                                .frame(width: 52, height: 52)
                                .background(AuraColor.containerLowest, in: Circle())
                                .auraCardShadow()
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("likeButton")
                    }

                    HStack(spacing: 8) {
                        ForEach(profile.interests, id: \.self) { InterestChip(text: $0) }
                    }

                    Text("\u{201C}\(profile.bio)\u{201D}")
                        .font(AuraFont.bodyMd()).foregroundStyle(.white.opacity(0.95))
                        .lineLimit(2)
                }
                .padding(20)
                .background(
                    LinearGradient(colors: [.clear, Color(hex: 0x1A0E04, alpha: 0.75)],
                                   startPoint: .center, endPoint: .bottom)
                )
            }
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .auraCardShadow()
            .offset(drag)
            .rotationEffect(.degrees(Double(drag.width / 22)))
            .gesture(isTop ? dragGesture : nil)
        }
        .aspectRatio(0.62, contentMode: .fit)
    }

    private var likePassStamp: some View {
        GeometryReader { _ in
            ZStack {
                stamp("LIKE", AuraColor.secondary, .leading, drag.width > 0)
                stamp("PASS", AuraColor.onSurfaceVariant, .trailing, drag.width < 0)
            }
            .padding(20)
        }
    }

    private func stamp(_ text: String, _ color: Color, _ align: Alignment, _ show: Bool) -> some View {
        Text(text)
            .font(.system(size: 26, weight: .heavy))
            .foregroundStyle(color)
            .padding(.horizontal, 14).padding(.vertical, 6)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(color, lineWidth: 3))
            .rotationEffect(.degrees(align == .leading ? -14 : 14))
            .opacity(show ? min(abs(drag.width) / 80, 1) : 0)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .init(horizontal: align == .leading ? .leading : .trailing, vertical: .top))
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { drag = $0.translation }
            .onEnded { value in
                if abs(value.translation.width) > 110 {
                    let dir: CGFloat = value.translation.width > 0 ? 1 : -1
                    withAnimation(.easeIn(duration: 0.22)) { drag = CGSize(width: dir * 600, height: value.translation.height) }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) { onConsume() }
                } else {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) { drag = .zero }
                }
            }
    }
}
