import SwiftUI

struct ProfileView: View {
    @Environment(MockBackend.self) private var backend
    @State private var showStore = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                profileHeader
                creditWallet
                interests
                ledger
                Spacer(minLength: 90)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
        }
        .background(AuraColor.surface)
        .sheet(isPresented: $showStore) { CreditStoreSheet() }
    }

    private var profileHeader: some View {
        VStack(spacing: 10) {
            AvatarView(asset: "p_me", name: "You", size: 96)
                .overlay(Circle().stroke(AuraColor.primary, lineWidth: 3))
                .auraCardShadow()
            Text("You, 29").font(AuraFont.headlineMd()).foregroundStyle(AuraColor.onSurface)
            Label("Valencia · Online", systemImage: "mappin.and.ellipse")
                .font(AuraFont.labelMd()).foregroundStyle(AuraColor.onSurfaceVariant)
        }
        .padding(.top, 8)
    }

    private var creditWallet: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Aura Credits").font(AuraFont.labelMd()).foregroundStyle(.white.opacity(0.85))
                    Text("\(backend.credits)").font(.system(size: 40, weight: .heavy)).foregroundStyle(.white)
                }
                Spacer()
                Image(systemName: "bolt.fill").font(.system(size: 32)).foregroundStyle(.white.opacity(0.9))
            }
            Button { showStore = true } label: {
                Text("Buy credits")
                    .font(.system(size: 15, weight: .bold)).foregroundStyle(AuraColor.primaryDeep)
                    .frame(maxWidth: .infinity).padding(.vertical, 12)
                    .background(.white, in: Capsule())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("buyCredits")
        }
        .padding(20)
        .background(
            LinearGradient(colors: [AuraColor.primary, AuraColor.tertiary],
                           startPoint: .topLeading, endPoint: .bottomTrailing),
            in: RoundedRectangle(cornerRadius: 24, style: .continuous)
        )
        .auraCardShadow()
    }

    private var interests: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Your frequency").font(AuraFont.labelMd()).foregroundStyle(AuraColor.onSurfaceVariant)
            FlowChips(items: ["Ceramics", "Sunrise Hikes", "Poetry", "Espresso", "Vinyl", "Climbing"])
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var ledger: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Recent activity").font(AuraFont.labelMd()).foregroundStyle(AuraColor.onSurfaceVariant)
            VStack(spacing: 0) {
                ForEach(backend.ledger) { tx in
                    HStack {
                        Text(tx.label).font(AuraFont.bodyMd()).foregroundStyle(AuraColor.onSurface)
                        Spacer()
                        Text(tx.amount > 0 ? "+\(tx.amount)" : "\(tx.amount)")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(tx.amount > 0 ? .green : AuraColor.secondaryDeep)
                    }
                    .padding(.vertical, 12)
                    if tx.id != backend.ledger.last?.id {
                        Rectangle().fill(AuraColor.outlineVariant.opacity(0.4)).frame(height: 1)
                    }
                }
            }
            .padding(.horizontal, 16)
            .background(AuraColor.containerLowest, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .auraCardShadow()
        }
    }
}

struct CreditStoreSheet: View {
    @Environment(MockBackend.self) private var backend
    @Environment(\.dismiss) private var dismiss
    private let packs = [(20, "$1.99"), (60, "$4.99"), (150, "$9.99")]

    var body: some View {
        VStack(spacing: 16) {
            Capsule().fill(AuraColor.outlineVariant).frame(width: 40, height: 5).padding(.top, 8)
            Text("Get Aura Credits").font(AuraFont.headlineMd()).foregroundStyle(AuraColor.onSurface)
            Text("Credits reserve meetup spots and boost your profile.")
                .font(AuraFont.bodyMd()).foregroundStyle(AuraColor.onSurfaceVariant)
                .multilineTextAlignment(.center)

            ForEach(packs, id: \.0) { pack in
                Button {
                    backend.buyCredits(pack.0); dismiss()
                } label: {
                    HStack {
                        Image(systemName: "bolt.fill").foregroundStyle(AuraColor.primary)
                        Text("\(pack.0) credits").font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(AuraColor.onSurface)
                        Spacer()
                        Text(pack.1).font(.system(size: 16, weight: .bold)).foregroundStyle(AuraColor.onPrimary)
                            .padding(.horizontal, 16).padding(.vertical, 8)
                            .background(AuraColor.primary, in: Capsule())
                    }
                    .padding(16)
                    .background(AuraColor.surfaceContainerLow, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                .buttonStyle(.plain)
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .background(AuraColor.surface)
        .presentationDetents([.medium, .large])
    }
}

/// Simple wrapping chip layout.
struct FlowChips: View {
    let items: [String]
    var body: some View {
        FlowLayout(spacing: 8) {
            ForEach(items, id: \.self) { InterestChip(text: $0) }
        }
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxW = proposal.width ?? .infinity
        var x: CGFloat = 0, y: CGFloat = 0, rowH: CGFloat = 0
        for v in subviews {
            let s = v.sizeThatFits(.unspecified)
            if x + s.width > maxW { x = 0; y += rowH + spacing; rowH = 0 }
            x += s.width + spacing
            rowH = max(rowH, s.height)
        }
        return CGSize(width: maxW == .infinity ? x : maxW, height: y + rowH)
    }
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX, y = bounds.minY, rowH: CGFloat = 0
        for v in subviews {
            let s = v.sizeThatFits(.unspecified)
            if x + s.width > bounds.maxX { x = bounds.minX; y += rowH + spacing; rowH = 0 }
            v.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(s))
            x += s.width + spacing
            rowH = max(rowH, s.height)
        }
    }
}
