import SwiftUI
import AppKit

struct CassetteView: View {
    @EnvironmentObject var state: PlaybackState

    var body: some View {
        AnimatedCassetteNSView(isPlaying: state.isPlaying)
            .aspectRatio(1764.0/1176.0, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(hex: "1A1A2E"), lineWidth: 2)
            )
            .overlay(WindowDragArea())
    }
}

/// NSViewRepresentable that displays the animated GIF and controls playback
struct AnimatedCassetteNSView: NSViewRepresentable {
    let isPlaying: Bool

    func makeNSView(context: Context) -> NSImageView {
        let imageView = NSImageView()
        imageView.imageScaling = .scaleProportionallyUpOrDown
        imageView.animates = false
        imageView.canDrawSubviewsIntoLayer = true

        // Load the animated GIF
        if let url = Bundle.main.url(forResource: "cassette_animated", withExtension: "gif") {
            imageView.image = NSImage(contentsOf: url)
        } else if let image = NSImage(contentsOfFile: "/Users/francoisdekock/WalkmanWidget/WalkmanWidget/Resources/cassette_animated.gif") {
            imageView.image = image
        }

        return imageView
    }

    func updateNSView(_ nsView: NSImageView, context: Context) {
        nsView.animates = isPlaying
    }
}

struct WindowDragArea: NSViewRepresentable {
    func makeNSView(context: Context) -> DragHandleView {
        let view = DragHandleView()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.clear.cgColor
        return view
    }

    func updateNSView(_ nsView: DragHandleView, context: Context) {}
}
