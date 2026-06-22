import AppKit

/// Talks to Apple Music & Spotify with **in-process** NSAppleScript on the main
/// thread. Each player has its own script, run only when that app is actually
/// running (detected via NSRunningApplication) — a script that merely *mentions*
/// an uninstalled app fails to compile, so we never reference one that's absent.
/// Callers are all on the main thread (PlayerStore is @MainActor).
enum MusicBridge {

    enum Command { case playPause, next, previous }

    private static let delimiter = "\u{2016}"
    private static let musicBundleID = "com.apple.Music"
    private static let spotifyBundleID = "com.spotify.client"
    private static var musicScript: NSAppleScript?
    private static var spotifyScript: NSAppleScript?

    // MARK: State

    static func fetchState(completion: @escaping (NowPlaying) -> Void) {
        completion(currentState())
    }

    private static func currentState() -> NowPlaying {
        let music = isRunning(musicBundleID) ? query(.music) : nil
        let spotify = isRunning(spotifyBundleID) ? query(.spotify) : nil
        if let s = spotify, s.isPlaying { return s }
        if let m = music, m.isPlaying { return m }
        if let s = spotify, s.hasContent { return s }
        if let m = music, m.hasContent { return m }
        return .empty
    }

    private static func isRunning(_ bundleID: String) -> Bool {
        !NSRunningApplication.runningApplications(withBundleIdentifier: bundleID).isEmpty
    }

    private enum Player { case music, spotify }

    private static func query(_ player: Player) -> NowPlaying {
        let script: NSAppleScript?
        switch player {
        case .music:
            if musicScript == nil { musicScript = NSAppleScript(source: musicSource) }
            script = musicScript
        case .spotify:
            if spotifyScript == nil { spotifyScript = NSAppleScript(source: spotifySource) }
            script = spotifyScript
        }
        guard let script else { return .empty }
        var err: NSDictionary?
        let result = script.executeAndReturnError(&err)
        if err != nil { return .empty }
        return parse(result.stringValue ?? "")
    }

    private static func parse(_ raw: String) -> NowPlaying {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return .empty }
        let f = trimmed.components(separatedBy: delimiter)
        guard f.count >= 8 else { return .empty }
        var np = NowPlaying()
        np.source = MusicSource(rawValue: f[0]) ?? .none
        np.isPlaying = (f[1] == "playing")
        np.title = f[2]
        np.artist = f[3]
        np.album = f[4]
        np.duration = Double(f[5]) ?? 0
        np.position = Double(f[6]) ?? 0
        np.artworkURL = f[7]
        return np
    }

    // MARK: Commands

    static func command(_ source: MusicSource, _ verb: Command) {
        guard source != .none else { return }
        let appleVerb: String
        switch verb {
        case .playPause: appleVerb = "playpause"
        case .next: appleVerb = "next track"
        case .previous: appleVerb = "previous track"
        }
        run("tell application \"\(source.appName)\" to \(appleVerb)")
    }

    static func seek(_ source: MusicSource, to seconds: Double) {
        guard source != .none else { return }
        run("tell application \"\(source.appName)\" to set player position to \(max(0, seconds))")
    }

    private static func run(_ source: String) {
        var err: NSDictionary?
        NSAppleScript(source: source)?.executeAndReturnError(&err)
    }

    // MARK: Artwork

    static func fetchMusicArtwork() -> NSImage? {
        let script = """
        tell application "Music"
            try
                return data of artwork 1 of current track
            on error
                return missing value
            end try
        end tell
        """
        var err: NSDictionary?
        guard let apple = NSAppleScript(source: script) else { return nil }
        let desc = apple.executeAndReturnError(&err)
        if err != nil { return nil }
        guard let data = desc.data as Data?, !data.isEmpty else { return nil }
        return NSImage(data: data)
    }

    static func fetchSpotifyArtwork(_ urlString: String, completion: @escaping (NSImage?) -> Void) {
        guard let url = URL(string: urlString) else { completion(nil); return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            let image = data.flatMap { NSImage(data: $0) }
            DispatchQueue.main.async { completion(image) }
        }.resume()
    }

    // MARK: Per-app scripts (unambiguous variable names — short ones collide with
    // the players' scripting terminology and break compilation).

    private static let musicSource = """
    set delim to "\u{2016}"
    tell application "Music"
        set npState to "stopped"
        set npTitle to ""
        set npArtist to ""
        set npAlbum to ""
        set npDur to 0
        set npPos to 0
        try
            set npState to (player state as string)
        end try
        try
            set npTitle to name of current track
            set npArtist to artist of current track
            set npAlbum to album of current track
            set npDur to duration of current track
        end try
        try
            set npPos to player position
        end try
    end tell
    return "Music" & delim & npState & delim & npTitle & delim & npArtist & delim & npAlbum & delim & (npDur as string) & delim & (npPos as string) & delim & ""
    """

    private static let spotifySource = """
    set delim to "\u{2016}"
    tell application "Spotify"
        set npState to "stopped"
        set npTitle to ""
        set npArtist to ""
        set npAlbum to ""
        set npDur to 0
        set npPos to 0
        set npArt to ""
        try
            set npState to (player state as string)
        end try
        try
            set npTitle to name of current track
            set npArtist to artist of current track
            set npAlbum to album of current track
            set npDur to (duration of current track) / 1000
            set npArt to artwork url of current track
        end try
        try
            set npPos to player position
        end try
    end tell
    return "Spotify" & delim & npState & delim & npTitle & delim & npArtist & delim & npAlbum & delim & (npDur as string) & delim & (npPos as string) & delim & npArt
    """
}
