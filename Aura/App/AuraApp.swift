import SwiftUI

@main
struct AuraApp: App {
    @State private var backend = MockBackend()

    var body: some Scene {
        WindowGroup {
            AppFlow()
                .environment(backend)
                .tint(AuraColor.primary)
                .preferredColorScheme(.light)
        }
    }
}

/// Routes between onboarding and the main tab shell. Launch arguments let the
/// screenshot driver deep-link straight to a screen, e.g. `-screen discover`.
struct AppFlow: View {
    @AppStorage("didOnboard") private var didOnboard = false
    @State private var startTab: RootTab = .map

    var body: some View {
        Group {
            if didOnboard {
                RootView(tab: $startTab)
            } else {
                OnboardingView { didOnboard = true }
            }
        }
        .onAppear(perform: applyLaunchArgs)
    }

    private func applyLaunchArgs() {
        let args = ProcessInfo.processInfo.arguments
        guard let i = args.firstIndex(of: "-screen"), i + 1 < args.count else { return }
        let screen = args[i + 1]
        if screen == "onboarding" { didOnboard = false; return }
        didOnboard = true
        startTab = RootTab(rawValue: screen) ?? .map
    }
}
