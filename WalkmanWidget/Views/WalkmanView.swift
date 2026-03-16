import SwiftUI

struct WalkmanView: View {
    @EnvironmentObject var state: PlaybackState
    @State private var showSettings = false

    var body: some View {
        ZStack {
            // Chassis body
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(hex: "8A8A8E"))
                .padding(1)
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(hex: "B8B8BC"))
                .padding(3)
                .padding(.bottom, 3)
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(hex: "1A1A2E"), lineWidth: 3)

            // Highlight at top
            VStack {
                LinearGradient(
                    colors: [Color(hex: "D0D0D4"), Color(hex: "B8B8BC")],
                    startPoint: .top, endPoint: .bottom
                )
                .frame(height: 16)
                .clipShape(UnevenRoundedRectangle(topLeadingRadius: 14, topTrailingRadius: 14))
                .padding(.horizontal, 3)
                .padding(.top, 3)
                Spacer()
            }

            // Main layout
            VStack(spacing: 6) {
                // Cassette image with gear overlay
                ZStack(alignment: .topTrailing) {
                    CassetteView()

                    Button(action: { showSettings.toggle() }) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "D4C4AA").opacity(0.9))
                                .frame(width: 22, height: 22)
                            Circle()
                                .stroke(Color(hex: "1A1A2E"), lineWidth: 1.5)
                                .frame(width: 22, height: 22)
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 9))
                                .foregroundColor(Color(hex: "1A1A2E"))
                        }
                    }
                    .buttonStyle(.plain)
                    .padding(4)
                    .popover(isPresented: $showSettings) {
                        SettingsView()
                            .environmentObject(state)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.top, 6)

                // LCD
                LCDView()
                    .environmentObject(state)
                    .frame(height: 50)
                    .padding(.horizontal, 10)

                // Buttons
                TransportButtonsView()
                    .environmentObject(state)
                    .padding(.horizontal, 10)

                // Bottom strip
                HStack(alignment: .center) {
                    FuzzKnobView()
                        .environmentObject(state)

                    Spacer()

                    VStack(spacing: 2) {
                        Text(state.currentSide.rawValue)
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(Color(hex: "1A1A2E"))
                        if state.isPlaying {
                            Circle()
                                .fill(Color(hex: "FF6B6B"))
                                .frame(width: 5, height: 5)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 6)
            }

            // Scanlines
            Canvas { context, size in
                for y in stride(from: CGFloat(0), to: size.height, by: 2) {
                    var line = Path()
                    line.move(to: CGPoint(x: 0, y: y))
                    line.addLine(to: CGPoint(x: size.width, y: y))
                    context.stroke(line, with: .color(.black.opacity(0.03)), lineWidth: 1)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .allowsHitTesting(false)

            // Flip prompt
            if state.needsFlip {
                ZStack {
                    Color.black.opacity(0.6)
                    VStack(spacing: 10) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(Color(hex: "7AFF7A"))
                        Text("FLIP CASSETTE")
                            .font(.system(size: 20, weight: .heavy, design: .monospaced))
                            .foregroundColor(Color(hex: "7AFF7A"))
                        Text("tap to continue")
                            .font(.system(size: 9, design: .monospaced))
                            .foregroundColor(Color(hex: "7AFF7A").opacity(0.6))
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .onTapGesture { state.flipSide() }
            }

            // Tape end
            if state.isTapeEnd {
                ZStack {
                    Color.black.opacity(0.6)
                    VStack(spacing: 10) {
                        Text("TAPE END")
                            .font(.system(size: 24, weight: .heavy, design: .monospaced))
                            .foregroundColor(Color(hex: "FF6B6B"))
                        Button("REWIND") { state.resetTape() }
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(Color(hex: "7AFF7A"))
                            .buttonStyle(.plain)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
        .frame(width: 280)
        .fixedSize(horizontal: false, vertical: true)
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        self.init(
            red: Double((rgb >> 16) & 0xFF) / 255,
            green: Double((rgb >> 8) & 0xFF) / 255,
            blue: Double(rgb & 0xFF) / 255
        )
    }
}
