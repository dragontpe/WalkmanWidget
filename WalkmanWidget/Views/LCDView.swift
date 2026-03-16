import SwiftUI

struct LCDView: View {
    @EnvironmentObject var state: PlaybackState
    @State private var marqueeOffset: CGFloat = 0
    private let marqueeTimer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()

    private var trackText: String {
        if let track = state.currentTrack {
            return "\(track.name) \u{2014} \(track.artist)"
        }
        return "NO TRACK"
    }

    private var timeDisplay: String {
        let elapsed = Int(state.sideElapsed)
        return String(format: "%02d:%02d", elapsed / 60, elapsed % 60)
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(hex: "2D4A2D"))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color(hex: "1A1A2E"), lineWidth: 2.5)
                )

            VStack(alignment: .leading, spacing: 4) {
                GeometryReader { geo in
                    Text(trackText)
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundColor(Color(hex: "7AFF7A"))
                        .shadow(color: Color(hex: "7AFF7A").opacity(0.4), radius: 1)
                        .fixedSize()
                        .offset(x: marqueeOffset)
                        .onReceive(marqueeTimer) { _ in
                            guard state.isPlaying else { return }
                            marqueeOffset -= 0.8
                            if marqueeOffset < -300 { marqueeOffset = geo.size.width }
                        }
                }
                .frame(height: 13)
                .clipped()

                HStack(spacing: 4) {
                    Text(state.currentSide.rawValue)
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(Color(hex: "7AFF7A"))

                    Text(timeDisplay)
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundColor(Color(hex: "7AFF7A").opacity(0.7))

                    Spacer()

                    HStack(spacing: 1.5) {
                        ForEach(0..<14, id: \.self) { i in
                            Rectangle()
                                .fill(Double(i) / 14.0 < state.sideProgress
                                      ? Color(hex: "7AFF7A")
                                      : Color(hex: "3D5A3D"))
                                .frame(width: 4, height: 6)
                        }
                    }
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
        }
    }
}
