import Foundation
import Combine
import SwiftUI

class PlaybackState: ObservableObject {
    @Published var isPlaying = false
    @Published var currentSide: CassetteSide = .sideA
    @Published var sideElapsed: TimeInterval = 0
    @Published var currentTrack: SpotifyTrack?
    @Published var needsFlip = false
    @Published var isTapeEnd = false
    @Published var fuzzLevel: Double = 0.08
    @Published var isFlipping = false

    @Published var fuzzEnabled: Bool = true {
        didSet {
            if fuzzEnabled && isPlaying {
                fuzzEngine.start()
            } else if !fuzzEnabled {
                fuzzEngine.stop()
            }
        }
    }

    @Published var alwaysOnTop: Bool = true {
        didSet { onAlwaysOnTopChanged?(alwaysOnTop) }
    }

    @Published var playlistURI: String = UserDefaults.standard.string(forKey: "playlistURI") ?? ""

    @Published var sideDuration: TimeInterval = {
        let saved = UserDefaults.standard.double(forKey: "sideDuration")
        return saved > 0 ? saved : 2700
    }() {
        didSet { UserDefaults.standard.set(sideDuration, forKey: "sideDuration") }
    }

    var onAlwaysOnTopChanged: ((Bool) -> Void)?

    var sideProgress: Double {
        guard sideDuration > 0 else { return 0 }
        return min(sideElapsed / sideDuration, 1.0)
    }

    var spoolLeftRadius: Double {
        currentSide == .sideA
            ? 0.8 - (0.5 * sideProgress)
            : 0.3 + (0.5 * sideProgress)
    }

    var spoolRightRadius: Double {
        currentSide == .sideA
            ? 0.3 + (0.5 * sideProgress)
            : 0.8 - (0.5 * sideProgress)
    }

    private var sideTimer: Timer?
    private var pollTimer: Timer?
    let fuzzEngine = TapeFuzzEngine()

    func play() {
        guard !needsFlip && !isTapeEnd else { return }

        // If nothing is playing yet and we have a playlist, start it
        if !SpotifyBridge.isPlaying() && !playlistURI.isEmpty {
            SpotifyBridge.playPlaylist(uri: playlistURI)
        } else {
            SpotifyBridge.play()
        }

        isPlaying = true
        if fuzzEnabled { fuzzEngine.start() }
        startTimers()

        // Poll after a short delay to let Spotify catch up
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.pollCurrentTrack()
        }
    }

    func pause() {
        SpotifyBridge.pause()
        isPlaying = false
        fuzzEngine.stop()
        stopTimers()
    }

    func togglePlayPause() {
        if isPlaying { pause() } else { play() }
    }

    func nextTrack() {
        SpotifyBridge.nextTrack()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.pollCurrentTrack()
        }
    }

    func previousTrack() {
        SpotifyBridge.previousTrack()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.pollCurrentTrack()
        }
    }

    func flipSide() {
        guard needsFlip else { return }
        isFlipping = true
        needsFlip = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
            guard let self = self else { return }
            self.currentSide = self.currentSide.next
            self.sideElapsed = 0
            self.isFlipping = false
            self.play()
        }
    }

    func loadPlaylist() {
        UserDefaults.standard.set(playlistURI, forKey: "playlistURI")
        sideElapsed = 0
        currentSide = .sideA
        needsFlip = false
        isTapeEnd = false

        if !playlistURI.isEmpty {
            SpotifyBridge.playPlaylist(uri: playlistURI)
            isPlaying = true
            if fuzzEnabled { fuzzEngine.start() }
            startTimers()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.pollCurrentTrack()
            }
        }
    }

    func setFuzzLevel(_ level: Double) {
        fuzzLevel = level
        fuzzEngine.volume = Float(level)
    }

    func resetTape() {
        pause()
        sideElapsed = 0
        currentSide = .sideA
        needsFlip = false
        isTapeEnd = false
    }

    // MARK: - Timers

    private func startTimers() {
        stopTimers()
        sideTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            DispatchQueue.main.async { self?.tickSide() }
        }
        pollTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { [weak self] _ in
            self?.pollCurrentTrack()
        }
    }

    private func stopTimers() {
        sideTimer?.invalidate()
        sideTimer = nil
        pollTimer?.invalidate()
        pollTimer = nil
    }

    private func tickSide() {
        guard isPlaying else { return }
        sideElapsed += 1

        if sideElapsed >= sideDuration {
            if currentSide == .sideA {
                pause()
                needsFlip = true
            } else {
                pause()
                isTapeEnd = true
            }
        }
    }

    private func pollCurrentTrack() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let track = SpotifyBridge.getCurrentTrack()
            DispatchQueue.main.async {
                self?.currentTrack = track
            }
        }
    }
}
