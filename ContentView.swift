//
//  ContentView.swift
//  JPOPPlayer
//
//  Created by Hyunjun Kim on 5/17/25.
//


import SwiftUI

struct ContentView: View {
    @StateObject var audioManager = AudioManager()
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
            VStack(spacing: 20) {
                Text(audioManager.songs[audioManager.currentIndex].title)
                    .font(.custom("GmarketSansTTFMedium", size: 24))
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text(audioManager.songs[audioManager.currentIndex].artist)
                    .font(.custom("GmarketSansTTFMedium", size: 18))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)

                Text(audioManager.currentLyric)
                    .font(.custom("GmarketSansTTFMedium", size: 20))
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [.black.opacity(0.3), .black.opacity(0.1)]),
                            startPoint: .top, endPoint: .bottom
                        )
                        .cornerRadius(12)
                        .shadow(radius: 5)
                    )
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
            .onChange(of: scenePhase) { phase in
                if phase == .background {
                    audioManager.saveCurrentPosition()
                }
            }
            .onAppear {
                audioManager.playPause()
            }
        }
    }
