import SwiftUI

/// Medium: art on the left, info + full transport on the right, progress beneath.
struct MediumView: View {
    @ObservedObject var store: PlayerStore

    var body: some View {
        HStack(spacing: Theme.s4) {
            ArtworkView(
                image: store.artwork,
                trackID: store.now.trackID,
                size: 92,
                corner: Theme.artCornerLarge
            )

            VStack(alignment: .leading, spacing: Theme.s3) {
                TrackText(store: store, titleSize: 15, artistSize: 13)

                PlaybackControls(store: store, spacing: 18, playSize: 20, sideSize: 15)
                    .padding(.leading, -8) // optically align first glyph to the text

                ProgressBarView(store: store, showTimes: true)
            }
        }
        .padding(Theme.s5)
    }
}
