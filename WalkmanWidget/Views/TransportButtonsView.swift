import SwiftUI

struct TransportButtonsView: View {
    @EnvironmentObject var state: PlaybackState

    var body: some View {
        HStack(spacing: 6) {
            TButton(symbol: "backward.end.fill") {
                state.previousTrack()
            }
            TButton(symbol: "backward.fill") {
                let pos = SpotifyBridge.getPlayerPosition()
                SpotifyBridge.setPlayerPosition(max(0, pos - 10))
            }
            TButton(symbol: state.isPlaying ? "pause.fill" : "play.fill", isMain: true) {
                state.togglePlayPause()
            }
            TButton(symbol: "forward.fill") {
                let pos = SpotifyBridge.getPlayerPosition()
                SpotifyBridge.setPlayerPosition(pos + 10)
            }
            TButton(symbol: "forward.end.fill") {
                state.nextTrack()
            }
        }
    }
}

struct TButton: View {
    let symbol: String
    var isMain: Bool = false
    let action: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            ZStack {
                // Shadow
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(hex: "3A4A5E"))
                    .offset(y: isPressed ? 0 : 2)

                // Face
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(hex: isMain ? "7A9AB5" : "6B8CAE"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(hex: "1A1A2E"), lineWidth: 2.5)
                    )
                    .offset(y: isPressed ? 2 : 0)

                Image(systemName: symbol)
                    .font(.system(size: isMain ? 14 : 11, weight: .bold))
                    .foregroundColor(Color(hex: "1A1A2E"))
                    .offset(y: isPressed ? 2 : 0)
            }
            .frame(width: isMain ? 48 : 40, height: 36)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in withAnimation(.easeOut(duration: 0.05)) { isPressed = true } }
                .onEnded { _ in withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) { isPressed = false } }
        )
    }
}
