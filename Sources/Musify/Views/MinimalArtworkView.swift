import SwiftUI

/// Minimal Artwork (Sleeve-style): a large cover with tiny transport controls that
/// fade in over the center on hover, and title / album / artist quietly underneath.
/// Designed to sit on a transparent window — text is white with a soft shadow so it
/// reads on any wallpaper.
struct MinimalArtworkView: View {
    @ObservedObject var store: PlayerStore
    var hovering: Bool

    private let art: CGFloat = 232

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.s3) {
            ArtworkView(
                image: store.artwork,
                trackID: store.now.trackID,
                size: art,
                corner: Theme.windowCorner - 4
            )
            .overlay(dragDots, alignment: .topLeading)
            .overlay(controls)

            info
        }
        .padding(Theme.s4)
    }

    @ViewBuilder
    private var info: some View {
        if store.now.hasContent {
            VStack(alignment: .leading, spacing: 2) {
                Text(store.now.title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.white)
                Text(store.now.album)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(.white.opacity(0.7))
                Text(store.now.artist)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.92))
            }
            .lineLimit(1)
            .truncationMode(.tail)
            .shadow(color: .black.opacity(0.3), radius: 2, y: 0.5)
            .frame(maxWidth: art, alignment: .leading)
            .padding(.horizontal, 2)
            .animation(.easeInOut(duration: 0.25), value: store.now.trackID)
        } else {
            Text("Not Playing")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white.opacity(0.7))
                .shadow(color: .black.opacity(0.4), radius: 4, y: 1)
                .frame(maxWidth: art, alignment: .leading)
        }
    }

    // The little grab-handle dots Sleeve shows in the corner — appear on hover.
    private var dragDots: some View {
        Image(systemName: "circle.grid.3x3.fill")
            .font(.system(size: 11))
            .foregroundStyle(.white.opacity(0.85))
            .shadow(color: .black.opacity(0.35), radius: 3)
            .padding(12)
            .opacity(hovering ? 1 : 0)
            .animation(Theme.hover, value: hovering)
    }

    private var controls: some View {
        // Scrim only appears with the controls so the cover stays clean at rest.
        ZStack {
            RoundedRectangle(cornerRadius: Theme.windowCorner - 4, style: .continuous)
                .fill(.black.opacity(hovering ? 0.28 : 0))
            PlaybackControls(store: store, spacing: 24, playSize: 28, sideSize: 19)
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.3), radius: 6, y: 1)
                .opacity(hovering ? 1 : 0)
                .scaleEffect(hovering ? 1 : 0.92)
        }
        .animation(Theme.hover, value: hovering)
        // Controls sit on artwork — always render them light.
        .environment(\.colorScheme, .dark)
    }
}
