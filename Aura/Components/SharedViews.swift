import SwiftUI

/// Photo placeholder. Tries a bundled asset; if absent, draws a deterministic
/// warm gradient seeded by the name so each person/meetup reads distinctly.
struct PhotoView: View {
    let asset: String
    let seed: String
    var body: some View {
        if UIImage(named: asset) != nil {
            Image(asset).resizable().aspectRatio(contentMode: .fill)
        } else {
            LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                .overlay(
                    LinearGradient(colors: [.clear, Color(hex: 0x78350F, alpha: 0.35)],
                                   startPoint: .center, endPoint: .bottom)
                )
        }
    }
    private var gradient: [Color] {
        let palettes: [[Color]] = [
            [Color(hex: 0xFFB95F), Color(hex: 0xF59E0B)],
            [Color(hex: 0xFE7488), Color(hex: 0xA93349)],
            [Color(hex: 0xF79A6C), Color(hex: 0x944A23)],
            [Color(hex: 0xFFDDB8), Color(hex: 0xF59E0B)],
        ]
        let idx = abs(seed.hashValue) % palettes.count
        return palettes[idx]
    }
}

/// Circular avatar with initial fallback.
struct AvatarView: View {
    let asset: String
    let name: String
    var size: CGFloat = 40
    var body: some View {
        PhotoView(asset: asset, seed: name)
            .frame(width: size, height: size)
            .clipShape(Circle())
            .overlay(
                Group {
                    if UIImage(named: asset) == nil {
                        Text(String(name.prefix(1)))
                            .font(.system(size: size * 0.4, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
            )
    }
}

/// Pill chip in 10% sunset-pink fill with full-color text (per design spec).
struct InterestChip: View {
    let text: String
    var body: some View {
        Text(text)
            .font(AuraFont.labelMd())
            .foregroundStyle(AuraColor.secondaryDeep)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(AuraColor.secondary.opacity(0.12), in: Capsule())
    }
}

/// Tactile amber primary button with the "squish" inner-shadow feel.
struct PrimaryButton: View {
    let title: String
    var icon: String? = nil
    let action: () -> Void
    @State private var pressed = false
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon { Image(systemName: icon) }
                Text(title).font(.system(size: 17, weight: .bold))
            }
            .foregroundStyle(AuraColor.onPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 17)
            .background(AuraColor.primary, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color(hex: 0x613B00, alpha: 0.25), lineWidth: 1)
                    .blendMode(.overlay)
            )
            .scaleEffect(pressed ? 0.97 : 1)
            .auraCardShadow()
        }
        .buttonStyle(.plain)
        .simultaneousGesture(DragGesture(minimumDistance: 0)
            .onChanged { _ in withAnimation(.easeOut(duration: 0.12)) { pressed = true } }
            .onEnded { _ in withAnimation(.easeOut(duration: 0.18)) { pressed = false } })
    }
}
