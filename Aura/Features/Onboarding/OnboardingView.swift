import SwiftUI
import AuthenticationServices

struct OnboardingView: View {
    var onContinue: () -> Void
    @State private var appear = false

    var body: some View {
        VStack(spacing: 0) {
            heroCard
                .padding(.horizontal, 20)
                .padding(.top, 8)

            Spacer(minLength: 24)

            VStack(spacing: 12) {
                Text("Real connections, offline.")
                    .font(AuraFont.headlineLg())
                    .foregroundStyle(AuraColor.onSurface)
                    .multilineTextAlignment(.center)
                Text("Meet people who share your frequency in the spaces you already love.")
                    .font(AuraFont.bodyLg())
                    .foregroundStyle(AuraColor.onSurfaceVariant)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }

            Spacer(minLength: 24)

            VStack(spacing: 12) {
                PrimaryButton(title: "Get Started", action: onContinue)
                    .accessibilityIdentifier("getStarted")

                SignInWithAppleButton(.signIn) { _ in } onCompletion: { _ in onContinue() }
                    .signInWithAppleButtonStyle(.whiteOutline)
                    .frame(height: 52)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        // Match warm style: soft container fill behind the system button.
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(AuraColor.surfaceContainerHigh)
                            .allowsHitTesting(false)
                            .opacity(0.0)
                    )
            }
            .padding(.horizontal, 20)

            socialProof
                .padding(.top, 28)
                .padding(.bottom, 8)

            pageDots.padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AuraColor.surface.ignoresSafeArea())
        .opacity(appear ? 1 : 0)
        .onAppear { withAnimation(.easeOut(duration: 0.5)) { appear = true } }
    }

    private var heroCard: some View {
        ZStack(alignment: .topTrailing) {
            PhotoView(asset: "onboarding_hero", seed: "golden hour friends")
                .frame(height: 320)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

            matchBadge.padding(16)

            VStack {
                Spacer()
                HStack {
                    Label("Blue Bottle Coffee", systemImage: "cup.and.saucer.fill")
                        .font(AuraFont.labelMd())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12).padding(.vertical, 8)
                        .background(.ultraThinMaterial, in: Capsule())
                    Spacer()
                }
                .padding(16)
            }
        }
        .auraCardShadow()
    }

    private var matchBadge: some View {
        HStack(spacing: 8) {
            Image(systemName: "heart.fill").foregroundStyle(AuraColor.secondary)
            VStack(alignment: .leading, spacing: 0) {
                Text("98% Match").font(.system(size: 13, weight: .bold)).foregroundStyle(AuraColor.onSurface)
                Text("Shared Frequency").font(AuraFont.labelSm()).foregroundStyle(AuraColor.onSurfaceVariant)
            }
        }
        .padding(.horizontal, 12).padding(.vertical, 8)
        .background(AuraColor.containerLowest, in: Capsule())
        .auraCardShadow()
    }

    private var socialProof: some View {
        VStack(spacing: 8) {
            HStack(spacing: -10) {
                ForEach(["p_sofia", "p_mateo", "p_liam"], id: \.self) { a in
                    AvatarView(asset: a, name: a, size: 36)
                        .overlay(Circle().stroke(AuraColor.surface, lineWidth: 2))
                }
                Text("12k+")
                    .font(AuraFont.labelSm()).foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(AuraColor.primaryDeep, in: Circle())
                    .overlay(Circle().stroke(AuraColor.surface, lineWidth: 2))
            }
            Text("Joined Aura this week in your city")
                .font(AuraFont.labelMd()).foregroundStyle(AuraColor.onSurfaceVariant)
        }
    }

    private var pageDots: some View {
        HStack(spacing: 6) {
            Capsule().fill(AuraColor.primary).frame(width: 18, height: 6)
            Circle().fill(AuraColor.outlineVariant).frame(width: 6, height: 6)
            Circle().fill(AuraColor.outlineVariant).frame(width: 6, height: 6)
        }
    }
}
