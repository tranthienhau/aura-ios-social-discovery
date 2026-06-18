import SwiftUI

/// "Aura Radiant" design system, ported from the Stitch design tokens (DESIGN.md).
/// Golden-hour warmth: warm off-white surfaces, amber primary, sunset-pink accents,
/// deep-cocoa text. No pure white, no pure black, no hard borders, soft amber shadows.
enum AuraColor {
    static let surface = Color(hex: 0xFFF8F5)
    static let surfaceContainerLow = Color(hex: 0xFFF1E9)
    static let surfaceContainer = Color(hex: 0xFCEBE1)
    static let surfaceContainerHigh = Color(hex: 0xF6E5DB)
    static let surfaceContainerHighest = Color(hex: 0xF0DFD6)
    static let containerLowest = Color(hex: 0xFFFFFF)

    static let onSurface = Color(hex: 0x221A14)        // deep cocoa
    static let onSurfaceVariant = Color(hex: 0x534434)
    static let outlineVariant = Color(hex: 0xD8C3AD)

    static let primary = Color(hex: 0xF59E0B)          // amber CTA
    static let primaryDeep = Color(hex: 0x855300)      // dark amber (icons / send)
    static let onPrimary = Color(hex: 0xFFFFFF)

    static let secondary = Color(hex: 0xFB7185)        // sunset pink (hearts)
    static let secondaryDeep = Color(hex: 0xA93349)

    static let tertiary = Color(hex: 0x944A23)
}

extension Color {
    init(hex: UInt32, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }
}

enum AuraFont {
    static func displayLg() -> Font { .system(size: 34, weight: .heavy) }
    static func headlineLg() -> Font { .system(size: 28, weight: .bold) }
    static func headlineMd() -> Font { .system(size: 22, weight: .semibold) }
    static func bodyLg() -> Font { .system(size: 17, weight: .regular) }
    static func bodyMd() -> Font { .system(size: 15, weight: .regular) }
    static func labelMd() -> Font { .system(size: 13, weight: .semibold) }
    static func labelSm() -> Font { .system(size: 11, weight: .medium) }
}

/// Level-1 ambient shadow with a warm amber tint (per the elevation spec).
extension View {
    func auraCardShadow() -> some View {
        shadow(color: Color(hex: 0x78350F, alpha: 0.10), radius: 18, x: 0, y: 8)
    }
    func auraOverlayShadow() -> some View {
        shadow(color: Color(hex: 0x78350F, alpha: 0.18), radius: 28, x: 0, y: 14)
    }
}
