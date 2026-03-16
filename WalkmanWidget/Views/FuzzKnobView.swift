import SwiftUI

struct FuzzKnobView: View {
    @EnvironmentObject var state: PlaybackState
    @State private var baseLevel: Double = 0.08

    private var knobAngle: Double {
        return -135 + state.fuzzLevel * 270
    }

    var body: some View {
        VStack(spacing: 3) {
            Text("FUZZ")
                .font(.system(size: 8, weight: .heavy, design: .monospaced))
                .foregroundColor(Color(hex: "1A1A2E"))

            ZStack {
                Circle()
                    .fill(Color(hex: "1A1A2E"))
                    .frame(width: 32, height: 32)
                    .offset(y: 1.5)

                Circle()
                    .fill(Color(hex: "6B8CAE"))
                    .frame(width: 30, height: 30)
                    .overlay(
                        Circle().stroke(Color(hex: "1A1A2E"), lineWidth: 2.5)
                    )

                Rectangle()
                    .fill(Color(hex: "F5EDD8"))
                    .frame(width: 2, height: 10)
                    .offset(y: -8)
                    .rotationEffect(.degrees(knobAngle))
            }

            Text(String(format: "%.0f%%", state.fuzzLevel * 100))
                .font(.system(size: 7, weight: .regular, design: .monospaced))
                .foregroundColor(Color(hex: "1A1A2E").opacity(0.6))
        }
        .frame(width: 50, height: 70)
        .contentShape(Rectangle())
        .gesture(
            DragGesture()
                .onChanged { value in
                    if abs(value.translation.height) < 2 && abs(value.translation.width) < 2 {
                        baseLevel = state.fuzzLevel
                    }
                    let delta = -Double(value.translation.height) / 100
                    state.setFuzzLevel(min(1.0, max(0, baseLevel + delta)))
                }
                .onEnded { _ in
                    baseLevel = state.fuzzLevel
                }
        )
    }
}
