import SwiftUI

/// A single transport button — SF Symbol, borderless, with a restrained press +
/// hover response. No glow, no fill chrome.
struct TransportButton: View {
    let symbol: String
    var size: CGFloat = 15
    let action: () -> Void

    @State private var hovering = false
    @State private var pressed = false

    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: size, weight: .medium))
                .foregroundStyle(hovering ? Color.primary : Color.primary.opacity(0.85))
                .frame(width: size + 16, height: size + 16)
                .contentShape(Rectangle())
                .scaleEffect(pressed ? 0.88 : 1)
        }
        .buttonStyle(.plain)
        .onHover { h in withAnimation(Theme.hover) { hovering = h } }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in withAnimation(Theme.hover) { pressed = true } }
                .onEnded { _ in withAnimation(Theme.hover) { pressed = false } }
        )
    }
}

/// Prev / Play-Pause / Next. `compact` drops the prev/next for the smallest style.
struct PlaybackControls: View {
    @ObservedObject var store: PlayerStore
    var spacing: CGFloat = 14
    var playSize: CGFloat = 19
    var sideSize: CGFloat = 14
    var showSides: Bool = true

    var body: some View {
        HStack(spacing: spacing) {
            if showSides {
                TransportButton(symbol: "backward.fill", size: sideSize) { store.previous() }
            }
            TransportButton(symbol: store.now.isPlaying ? "pause.fill" : "play.fill", size: playSize) {
                store.playPause()
            }
            if showSides {
                TransportButton(symbol: "forward.fill", size: sideSize) { store.next() }
            }
        }
    }
}
