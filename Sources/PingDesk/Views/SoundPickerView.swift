import SwiftUI
import AppKit

struct SoundPickerView: View {
    @Binding var selectedSound: String?

    static let systemSounds: [String] = [
        "Basso", "Blow", "Bottle", "Frog", "Funk", "Glass",
        "Hero", "Morse", "Ping", "Pop", "Purr", "Sosumi",
        "Submarine", "Tink"
    ]

    var body: some View {
        HStack {
            Picker("Sound", selection: $selectedSound) {
                Text("Default").tag(String?.none)
                ForEach(Self.systemSounds, id: \.self) { sound in
                    Text(sound).tag(String?.some(sound))
                }
            }
            Button {
                previewSound()
            } label: {
                Image(systemName: "play.circle")
            }
            .buttonStyle(.borderless)
            .disabled(selectedSound == nil)
        }
    }

    private func previewSound() {
        guard let soundName = selectedSound else { return }
        NSSound(named: soundName)?.play()
    }
}
