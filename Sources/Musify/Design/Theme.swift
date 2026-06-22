import SwiftUI

/// Central design tokens. Everything understated: one corner family,
/// a small spacing scale, semantic colors, SF Pro typography.
enum Theme {
    // Corner radii (spec: soft 20–28pt for the window, tighter for art).
    static let windowCorner: CGFloat = 24
    static let artCornerLarge: CGFloat = 14
    static let artCornerSmall: CGFloat = 10

    // Spacing scale.
    static let s1: CGFloat = 4
    static let s2: CGFloat = 8
    static let s3: CGFloat = 12
    static let s4: CGFloat = 16
    static let s5: CGFloat = 20

    // Hairline border — barely-there definition against any wallpaper.
    static var hairline: Color { Color.primary.opacity(0.08) }

    // Typography. The system font *is* SF Pro; large sizes use Display optically.
    static func title(_ size: CGFloat) -> Font { .system(size: size, weight: .semibold) }
    static func subtitle(_ size: CGFloat) -> Font { .system(size: size, weight: .regular) }
    static func time() -> Font { .system(size: 11, weight: .medium).monospacedDigit() }

    // Animations.
    static let crossfade: Animation = .easeInOut(duration: 0.45)
    static let appear: Animation = .spring(response: 0.42, dampingFraction: 0.82)
    static let hover: Animation = .spring(response: 0.28, dampingFraction: 0.9)
}

/// Per-style window sizes, kept in one place so the panel and the views agree.
enum WidgetStyle: String, CaseIterable, Identifiable {
    case compact, medium, minimal
    var id: String { rawValue }

    var title: String {
        switch self {
        case .compact: return "Compact"
        case .medium: return "Medium"
        case .minimal: return "Minimal Artwork"
        }
    }

    var size: CGSize {
        switch self {
        case .compact: return CGSize(width: 264, height: 96)
        case .medium: return CGSize(width: 352, height: 172)
        case .minimal: return CGSize(width: 264, height: 420)
        }
    }
}
