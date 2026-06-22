import SwiftUI

/// Composes the active style, the background material, and the global motion:
/// hover tracking, a gentle spring on first appearance, and smooth style changes.
struct RootView: View {
    @ObservedObject var store: PlayerStore
    @ObservedObject var settings: WidgetSettings

    @State private var hovering = false
    @State private var appeared = false

    var body: some View {
        content
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: Theme.windowCorner, style: .continuous))
            // No panel chrome when transparent — just the content floats.
            .overlay(
                RoundedRectangle(cornerRadius: Theme.windowCorner, style: .continuous)
                    .strokeBorder(settings.transparentBackground ? .clear : Theme.hairline, lineWidth: 0.5)
            )
            .onHover { h in withAnimation(Theme.hover) { hovering = h } }
            .scaleEffect(appeared ? 1 : 0.96)
            .opacity(appeared ? 1 : 0)
            .onAppear { withAnimation(Theme.appear) { appeared = true } }
            .animation(Theme.appear, value: settings.style)
            // Pin to the top-left so any surplus window height (the invisible
            // transparent area for Minimal) sits below the content, never clipping it.
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    @ViewBuilder
    private var content: some View {
        switch settings.style {
        case .compact:
            CompactView(store: store)
        case .medium:
            MediumView(store: store)
        case .minimal:
            MinimalArtworkView(store: store, hovering: hovering)
        }
    }

    @ViewBuilder
    private var background: some View {
        if settings.transparentBackground {
            Color.clear
        } else {
            VisualEffectView(material: .hudWindow)
        }
    }
}
