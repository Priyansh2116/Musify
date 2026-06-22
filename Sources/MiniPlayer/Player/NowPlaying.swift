import Foundation

/// Which app is driving the system's audio. The bridge picks the one that's
/// actually playing, falling back to whichever is running.
enum MusicSource: String {
    case appleMusic = "Music"
    case spotify = "Spotify"
    case none

    var appName: String { rawValue }
}

/// A single immutable snapshot of the current track + transport state.
struct NowPlaying: Equatable {
    var source: MusicSource = .none
    var isPlaying: Bool = false
    var title: String = ""
    var artist: String = ""
    var album: String = ""
    var duration: Double = 0      // seconds
    var position: Double = 0      // seconds
    var artworkURL: String = ""   // Spotify only; Music delivers raw bytes

    var hasContent: Bool { source != .none && !title.isEmpty }

    /// Stable identity for a track — drives artwork crossfades.
    var trackID: String { "\(source.rawValue)|\(title)|\(artist)|\(album)" }

    static let empty = NowPlaying()
}
