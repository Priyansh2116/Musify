import SwiftUI
import Combine

/// Observable source of truth for the views. Polls the bridge once a second,
/// keeps artwork in sync on track changes, and interpolates playback position
/// between polls so the progress bar stays smooth.
@MainActor
final class PlayerStore: ObservableObject {
    @Published private(set) var now: NowPlaying = .empty
    @Published private(set) var artwork: NSImage?

    // Position interpolation anchors.
    private var anchorPosition: Double = 0
    private var anchorDate: Date = .now

    private var timer: Timer?
    private var lastTrackID: String = ""

    func start() {
        poll()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.poll() }
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    /// Smoothly-advancing playback position, valid to read every frame.
    var livePosition: Double {
        guard now.isPlaying else { return anchorPosition }
        let advanced = anchorPosition + Date.now.timeIntervalSince(anchorDate)
        return min(advanced, now.duration > 0 ? now.duration : advanced)
    }

    var fraction: Double {
        guard now.duration > 0 else { return 0 }
        return max(0, min(1, livePosition / now.duration))
    }

    // MARK: Transport

    func playPause() {
        // Optimistic flip for instant feedback; the next poll corrects it.
        now.isPlaying.toggle()
        reanchor(now.position)
        MusicBridge.command(now.source, .playPause)
    }

    func next() { MusicBridge.command(now.source, .next) }
    func previous() { MusicBridge.command(now.source, .previous) }

    func seek(toFraction f: Double) {
        guard now.duration > 0 else { return }
        let seconds = max(0, min(1, f)) * now.duration
        reanchor(seconds)
        MusicBridge.seek(now.source, to: seconds)
    }

    // MARK: Polling

    private func poll() {
        MusicBridge.fetchState { [weak self] snapshot in
            self?.apply(snapshot)
        }
    }

    private func apply(_ snapshot: NowPlaying) {
        let trackChanged = snapshot.trackID != lastTrackID

        // Re-anchor position from the authoritative poll.
        reanchor(snapshot.position)
        now = snapshot

        if trackChanged {
            lastTrackID = snapshot.trackID
            loadArtwork(for: snapshot)
        }
        if !snapshot.hasContent { artwork = nil }
    }

    private func reanchor(_ position: Double) {
        anchorPosition = position
        anchorDate = .now
    }

    private func loadArtwork(for snapshot: NowPlaying) {
        switch snapshot.source {
        case .appleMusic:
            artwork = MusicBridge.fetchMusicArtwork()
        case .spotify:
            MusicBridge.fetchSpotifyArtwork(snapshot.artworkURL) { [weak self] image in
                // Ignore late arrivals for tracks we've already moved past.
                guard let self, self.now.trackID == snapshot.trackID else { return }
                self.artwork = image
            }
        case .none:
            artwork = nil
        }
    }
}
