import Foundation
import AppKit

enum SpotifyBridge {

    @discardableResult
    private static func runScript(_ source: String) -> String? {
        let script = NSAppleScript(source: source)
        var error: NSDictionary?
        let result = script?.executeAndReturnError(&error)
        if let error = error {
            print("AppleScript error: \(error)")
            return nil
        }
        return result?.stringValue
    }

    /// Run a script but reactivate our app afterward so Spotify doesn't steal focus
    private static func runWithoutActivation(_ source: String) {
        runScript(source)
        DispatchQueue.main.async {
            NSApp.activate(ignoringOtherApps: false)
        }
    }

    static func play() {
        // Use "using terms from" to avoid activating Spotify
        runScript("""
        tell application "Spotify"
            play
            set frontmost to false
        end tell
        """)
    }

    static func pause() {
        runScript(#"tell application "Spotify" to pause"#)
    }

    static func nextTrack() {
        runScript(#"tell application "Spotify" to next track"#)
    }

    static func previousTrack() {
        runScript(#"tell application "Spotify" to previous track"#)
    }

    static func playPause() {
        runScript(#"tell application "Spotify" to playpause"#)
    }

    static func isPlaying() -> Bool {
        let result = runScript(#"tell application "Spotify" to player state as string"#)
        return result == "playing"
    }

    static func getCurrentTrack() -> SpotifyTrack? {
        let source = """
        tell application "Spotify"
            if player state is stopped then return ""
            set trackName to name of current track
            set trackArtist to artist of current track
            set trackURI to spotify url of current track
            set trackDuration to duration of current track
            return trackName & "|||" & trackArtist & "|||" & trackURI & "|||" & (trackDuration as string)
        end tell
        """
        guard let result = runScript(source), !result.isEmpty else { return nil }
        let parts = result.components(separatedBy: "|||")
        guard parts.count >= 4 else { return nil }
        return SpotifyTrack(
            name: parts[0],
            artist: parts[1],
            uri: parts[2],
            durationMs: Int(parts[3]) ?? 0
        )
    }

    static func getPlayerPosition() -> Double {
        let result = runScript(#"tell application "Spotify" to player position"#)
        return Double(result ?? "0") ?? 0
    }

    static func setPlayerPosition(_ position: Double) {
        runScript("tell application \"Spotify\" to set player position to \(position)")
    }

    static func playTrack(uri: String, contextURI: String) {
        runScript("tell application \"Spotify\" to play track \"\(uri)\" in context \"\(contextURI)\"")
    }

    static func playPlaylist(uri: String) {
        let spotifyURI = normalizeToURI(uri)
        runScript("""
        tell application "Spotify"
            play track "\(spotifyURI)"
            set frontmost to false
        end tell
        """)
    }

    static func isRunning() -> Bool {
        let result = runScript(#"tell application "System Events" to (name of processes) contains "Spotify""#)
        return result == "true"
    }

    /// Converts Spotify URLs to URIs. Handles both formats:
    ///   https://open.spotify.com/playlist/37i9dQZF1DXcBWIGoYBM5M?si=abc123
    ///   spotify:playlist:37i9dQZF1DXcBWIGoYBM5M
    static func normalizeToURI(_ input: String) -> String {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)

        // Already a URI
        if trimmed.hasPrefix("spotify:") {
            return trimmed
        }

        // URL format: https://open.spotify.com/playlist/ID?si=...
        if let url = URL(string: trimmed),
           let host = url.host,
           host.contains("spotify.com") {
            let components = url.pathComponents.filter { $0 != "/" }
            // pathComponents: ["playlist", "37i9dQZF1DXcBWIGoYBM5M"]
            if components.count >= 2 {
                let type = components[0]  // "playlist", "album", "track"
                let id = components[1]
                return "spotify:\(type):\(id)"
            }
        }

        // Unknown format, return as-is
        return trimmed
    }
}
