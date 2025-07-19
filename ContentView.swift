import SwiftUI

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject var audioManager = AudioManager()
    @Environment(\.scenePhase) private var scenePhase
    @State private var showPlaylistView = false

    var currentFontName: String {
        let languageCode = Locale.current.language.languageCode?.identifier
        switch languageCode {
        case "ja":
            return "A-OTF Shin Go Pro M"
        case "ko":
            fallthrough
        default:
            return "GmarketSansTTFMedium"
        }
    }
    
    var currentDuration: TimeInterval {
        let value = audioManager.player.currentItem?.duration.seconds ?? 0
        return value.isNaN || value < 0 ? 0 : value
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text(audioManager.songs[audioManager.currentIndex].title)
                    .font(.custom(currentFontName, size: 24))
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(.label))

                Text(audioManager.songs[audioManager.currentIndex].artist)
                    .font(.custom(currentFontName, size: 18))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(.label))

                Text(audioManager.currentLyric)
                    .font(.custom(currentFontName, size: 20))
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.3),
                                colorScheme == .dark ? Color.white.opacity(0.05) : Color.black.opacity(0.1)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .cornerRadius(12)
                        .shadow(radius: 5)
                    )
                    .padding(.horizontal)
                    .foregroundColor(Color(.label))
                
                let duration = currentDuration
                let safeDuration = (duration.isNaN || duration < 0) ? 0 : duration
                Slider(value: Binding(
                    get: { min(audioManager.currentTime, max(safeDuration, 1)) },
                    set: { audioManager.currentTime = min($0, max(safeDuration, 1)) }
                ), in: 0...max(safeDuration, 1), onEditingChanged: { editing in
                    if !editing {
                        audioManager.seek(to: audioManager.currentTime)
                    }
                })
                .accentColor(.blue)
                .padding(.horizontal)

                HStack {
                    Text(formatTime(audioManager.currentTime))
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                    Text(formatTime(duration))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)

                HStack(spacing: 40) {
                    // Previous button with haptic
                    Button(action: {
                        audioManager.previous()
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    }) {
                        Image(systemName: "backward.fill")
                    }

                    // Play/Pause button with haptic
                    Button(action: {
                        audioManager.playPause()
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    }) {
                        Image(systemName: audioManager.isPlaying ? "pause.fill" : "play.fill")
                    }

                    // Next button with haptic
                    Button(action: {
                        audioManager.next()
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    }) {
                        Image(systemName: "forward.fill")
                    }
                }
                .font(.largeTitle)

                // Repeat button
                Button(action: {
                    audioManager.toggleRepeat()
                }) {
                    Image(systemName: audioManager.isRepeating ? "repeat.1" : "repeat")
                        .foregroundColor(audioManager.isRepeating ? .blue : .primary)
                }
                .font(.title2)
                .padding(.top, 10)
            }
            .padding()
            .background(Color(.systemBackground))
            .onChange(of: scenePhase) { phase in
                if phase == .background {
                    audioManager.saveCurrentPosition()
                }
            }
            .onAppear { }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showPlaylistView = true
                    }) {
                        Image(systemName: "music.note.list")
                    }
                }
            }
            .sheet(isPresented: $showPlaylistView) {
                PlaylistView(audioManager: audioManager)
            }
        }
    }
    
    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
