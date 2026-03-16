import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var state: PlaybackState
    @State private var uriText: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("SETTINGS")
                .font(.system(size: 14, weight: .bold, design: .monospaced))

            VStack(alignment: .leading, spacing: 4) {
                Text("Spotify Playlist URI")
                    .font(.system(size: 10, weight: .medium))
                TextField("spotify:playlist:...", text: $uriText)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 11, design: .monospaced))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Side duration")
                    .font(.system(size: 10, weight: .medium))
                Picker("", selection: Binding(
                    get: { Int(state.sideDuration / 60) },
                    set: { state.sideDuration = TimeInterval($0 * 60) }
                )) {
                    Text("30 min").tag(30)
                    Text("45 min").tag(45)
                    Text("60 min").tag(60)
                }
                .pickerStyle(.segmented)
            }

            Toggle("Tape fuzz enabled", isOn: $state.fuzzEnabled)
                .font(.system(size: 11))

            Toggle("Always on top", isOn: $state.alwaysOnTop)
                .font(.system(size: 11))

            Button("Save & Reload Playlist") {
                state.playlistURI = uriText
                state.loadPlaylist()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
        }
        .padding()
        .frame(width: 260)
        .onAppear {
            uriText = state.playlistURI
        }
    }
}
