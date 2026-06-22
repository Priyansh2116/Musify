import SwiftUI

/// Compact: 64×64 art, title + artist, a single play/pause on the trailing edge.
struct CompactView: View {
    @ObservedObject var store: PlayerStore

    var body: some View {
        HStack(spacing: Theme.s3) {
            ArtworkView(
                image: store.artwork,
                trackID: store.now.trackID,
                size: 64,
                corner: Theme.artCornerSmall
            )
            TrackText(store: store, titleSize: 13, artistSize: 12)
            PlaybackControls(store: store, playSize: 17, showSides: false)
                .padding(.trailing, 2)
        }
        .padding(Theme.s4)
    }
}
