//
//  AudioManager.swift
//  JPOPPlayer
//
//  Created by Hyunjun Kim on 5/17/25.
//


import Foundation
import AVFoundation
import MediaPlayer
import UIKit

class AudioManager: ObservableObject {
    @Published var isPlaying = false
    @Published var currentLyric: String = ""
    @Published var isRepeating: Bool = false

    private var player: AVPlayer!
    private var timeObserverToken: Any?

    var songs: [Song] = []
    var currentIndex = UserDefaults.standard.integer(forKey: "lastSongIndex")

    init() {
        setupSongs()
        setupPlayer()
        setupRemoteCommandCenter()
        configureAudioSession()
    }

    private func setupSongs() {
        songs = [
            Song(
                title: "",
                artist: "",
                fileName: "", // Reaplce with actual audio file names
                albumImageName: "", // Replace with actual image names
                lyrics: [
                    (0.0, ""), // Replace with your sync time and lyrics
                    (3.0, ""),
                ]
            )
            // You can add more songs here
        ]
    }


    private func setupPlayer() {
        let song = songs[currentIndex]
        guard let url = Bundle.main.url(forResource: song.fileName, withExtension: "mp3") else { return }
        player = AVPlayer(url: url)

        let lastTime = loadLastPosition(for: song)
        let targetTime = CMTime(seconds: lastTime, preferredTimescale: 1)
        player.seek(to: targetTime)

        observeTime()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem
        )
    }

    private func observeTime() {
        let interval = CMTime(seconds: 1, preferredTimescale: 1)
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            self?.updateLyric(for: time.seconds)
        }
    }

    private func updateLyric(for time: TimeInterval) {
        let song = songs[currentIndex]
        let matched = song.lyrics.last(where: { $0.time <= time })?.text ?? ""
        if matched != currentLyric {
            currentLyric = matched
            updateNowPlayingInfo()
        }
    }

    private func updateNowPlayingInfo() {
        let song = songs[currentIndex]
        var info: [String: Any] = [
            MPMediaItemPropertyArtist: song.artist,
            MPMediaItemPropertyTitle: currentLyric,
            MPNowPlayingInfoPropertyPlaybackRate: isPlaying ? 1.0 : 0.0
        ]

        if let image = UIImage(named: song.albumImageName) {
            let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
            info[MPMediaItemPropertyArtwork] = artwork
        }

        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    private func setupRemoteCommandCenter() {
        let center = MPRemoteCommandCenter.shared()
        center.playCommand.addTarget { [weak self] _ in self?.playPause(); return .success }
        center.pauseCommand.addTarget { [weak self] _ in self?.playPause(); return .success }
        center.nextTrackCommand.addTarget { [weak self] _ in self?.next(); return .success }
        center.previousTrackCommand.addTarget { [weak self] _ in self?.previous(); return .success }
    }

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("오디오 세션 설정 실패: \(error)")
        }
    }

    func playPause() {
        isPlaying.toggle()
        isPlaying ? player.play() : player.pause()
        updateNowPlayingInfo()
    }

    func next() {
        saveCurrentPosition()
        currentIndex = (currentIndex + 1) % songs.count
        resetCurrentSongData()
        replaceCurrentSong()
    }

    func previous() {
        saveCurrentPosition()
        currentIndex = (currentIndex - 1 + songs.count) % songs.count
        resetCurrentSongData()
        replaceCurrentSong()
    }

    private func resetCurrentSongData() {
        currentLyric = ""
        let song = songs[currentIndex]
        let key = lastPositionKey(for: song)
        UserDefaults.standard.set(0, forKey: key)
    }

    func replaceCurrentSong() {
        player.pause()
        if let token = timeObserverToken {
            player.removeTimeObserver(token)
            timeObserverToken = nil
        }
        setupPlayer()
        if isPlaying { player.play() }
        updateNowPlayingInfo()
    }

    private func lastPositionKey(for song: Song) -> String {
        return "lastPosition_\(song.fileName)"
    }

    func saveCurrentPosition() {
        guard let currentItem = player.currentItem else { return }
        let currentTime = currentItem.currentTime().seconds
        let key = lastPositionKey(for: songs[currentIndex])
        UserDefaults.standard.set(currentTime, forKey: key)
        UserDefaults.standard.set(currentIndex, forKey: "lastSongIndex")
    }

    private func loadLastPosition(for song: Song) -> TimeInterval {
        let key = lastPositionKey(for: song)
        return UserDefaults.standard.double(forKey: key)
    }

    @objc private func playerDidFinishPlaying(_ notification: Notification) {
        if isRepeating {
            replaceCurrentSong()
        } else {
            next()
        }
    }

    func toggleRepeat() {
        isRepeating.toggle()
    }
}
