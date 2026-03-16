import Foundation

struct SpotifyTrack: Identifiable, Equatable {
    let id = UUID()
    var name: String
    var artist: String
    var uri: String
    var durationMs: Int

    static func == (lhs: SpotifyTrack, rhs: SpotifyTrack) -> Bool {
        lhs.uri == rhs.uri
    }
}
