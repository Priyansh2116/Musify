import SwiftUI

/// Album artwork with a calm crossfade + slight zoom whenever the track changes.
/// The transition is keyed on `trackID`, so a new cover fades/scales in while the
/// previous one fades/scales out.
struct ArtworkView: View {
    let image: NSImage?
    let trackID: String
    let size: CGFloat
    let corner: CGFloat

    var body: some View {
        ZStack {
            placeholder
            if let image {
                Image(nsImage: image)
                    .resizable()
                    .interpolation(.high)
                    .aspectRatio(contentMode: .fill)
                    .id(trackID)
                    .transition(.opacity.combined(with: .scale(scale: 1.03)))
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: corner, style: .continuous)
                .strokeBorder(Theme.hairline, lineWidth: 0.5)
        )
        .animation(Theme.crossfade, value: trackID)
    }

    private var placeholder: some View {
        RoundedRectangle(cornerRadius: corner, style: .continuous)
            .fill(Color.primary.opacity(0.06))
            .overlay(
                Image(systemName: "music.note")
                    .font(.system(size: size * 0.3, weight: .light))
                    .foregroundStyle(.secondary.opacity(0.5))
            )
    }
}
