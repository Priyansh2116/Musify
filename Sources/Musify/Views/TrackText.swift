import SwiftUI

/// Title + artist block. Truncates cleanly; falls back to a quiet "Not Playing".
struct TrackText: View {
    @ObservedObject var store: PlayerStore
    var titleSize: CGFloat = 13
    var artistSize: CGFloat = 12
    var alignment: HorizontalAlignment = .leading
    var spacing: CGFloat = 2

    var body: some View {
        VStack(alignment: alignment, spacing: spacing) {
            if store.now.hasContent {
                Text(store.now.title)
                    .font(Theme.title(titleSize))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                Text(store.now.artist)
                    .font(Theme.subtitle(artistSize))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
            } else {
                Text("Not Playing")
                    .font(Theme.title(titleSize))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: alignment == .leading ? .leading : .center)
        .animation(.easeInOut(duration: 0.25), value: store.now.trackID)
    }
}
