import AVFoundation
import Foundation

class TapeFuzzEngine {
    private var player: AVAudioPlayer?
    private var isRunning = false

    var volume: Float = 0.3 {
        didSet {
            player?.volume = min(max(volume, 0), 1.0)
        }
    }

    init() {
        setupPlayer()
    }

    private func setupPlayer() {
        var url: URL?

        // Try bundle first
        if let bundleURL = Bundle.main.url(forResource: "tape_hiss", withExtension: "wav") {
            url = bundleURL
            NSLog("TapeFuzzEngine: found in bundle at %@", bundleURL.path)
        } else {
            // Fallback for development
            let devPath = "/Users/francoisdekock/WalkmanWidget/WalkmanWidget/Resources/tape_hiss.wav"
            if FileManager.default.fileExists(atPath: devPath) {
                url = URL(fileURLWithPath: devPath)
                NSLog("TapeFuzzEngine: using dev path %@", devPath)
            }
        }

        guard let url = url else {
            NSLog("TapeFuzzEngine: tape_hiss.wav NOT FOUND anywhere")
            return
        }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = -1
            player?.volume = volume
            player?.prepareToPlay()
            NSLog("TapeFuzzEngine: loaded OK, duration=%.1f, volume=%.2f", player?.duration ?? 0, volume)
        } catch {
            NSLog("TapeFuzzEngine: FAILED to load - %@", error.localizedDescription)
        }
    }

    func start() {
        guard !isRunning else { return }
        if player == nil { setupPlayer() }
        player?.volume = volume
        let ok = player?.play() ?? false
        isRunning = ok
        NSLog("TapeFuzzEngine: start() -> playing=%d, volume=%.2f", ok, volume)
    }

    func stop() {
        player?.pause()
        isRunning = false
        NSLog("TapeFuzzEngine: stopped")
    }

    deinit {
        stop()
    }
}
