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
    @Published var playlists: [Playlist] = []
    @Published var currentPlaylist: Playlist?
    @Published var currentTime: TimeInterval = 0

    var player: AVPlayer!
    private var timeObserverToken: Any?

    var songs: [Song] = []
    var currentIndex = UserDefaults.standard.integer(forKey: "lastSongIndex")

    init() {
        setupSongs()
        setupRemoteCommandCenter()
        configureAudioSession()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleBluetoothConnection),
            name: AVAudioSession.routeChangeNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: nil
        )
        
        // 이전 상태가 재생 중이었으면 자동 재생
        isPlaying = true
        objectWillChange.send()
        setupPlayer()
        updateNowPlayingInfo()
    }
    private func setupSongs() {
        if let playlist = currentPlaylist {
            songs = playlist.songs
        } else {
            songs = SongLibrary.songs
        }
    }

    private func setupPlayer() {
        guard songs.indices.contains(currentIndex) else {
            return
        }
        let song = songs[currentIndex]
        guard let url = Bundle.main.url(forResource: song.fileName, withExtension: "mp3") else {
            return
        }
        player = AVPlayer(url: url)

        let lastTime = loadLastPosition(for: song)
        let targetTime = CMTime(seconds: lastTime, preferredTimescale: 1)
        player.seek(to: targetTime)

        observeTime()
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            return
        }
        if isPlaying {
            Task {
                guard let item = player.currentItem else { return }
                do {
                    let _ = try await item.asset.load(.isPlayable)
                    player.play()
                } catch {
                    // Handle error if needed
                }
            }
        } else {
        }
    }

    private func observeTime() {
        let interval = CMTime(seconds: 1, preferredTimescale: 1)
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            self?.currentTime = time.seconds
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
            MPMediaItemPropertyAlbumTitle: song.title,
            MPMediaItemPropertyArtist: song.artist,
            MPMediaItemPropertyTitle: currentLyric,
            MPMediaItemPropertyAlbumTrackCount: 13,
            MPMediaItemPropertyAlbumTrackNumber: song.trackNumber,
            MPMediaItemPropertyGenre: "J-POP",
            MPNowPlayingInfoPropertyPlaybackRate: isPlaying ? 1.0 : 0.0
        ]

        if let image = UIImage(named: song.albumImageName) {
            let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
            info[MPMediaItemPropertyArtwork] = artwork
        }

        if let currentItem = player.currentItem {
            info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentItem.currentTime().seconds

            Task {
                do {
                    let duration = try await currentItem.asset.load(.duration)
                    DispatchQueue.main.async {
                        info[MPMediaItemPropertyPlaybackDuration] = duration.seconds
                        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
                    }
                } catch {
                    // Handle error if needed
                }
            }
        } else {
            MPNowPlayingInfoCenter.default().nowPlayingInfo = info
        }
    }

    private func setupRemoteCommandCenter() {
        let center = MPRemoteCommandCenter.shared()
        center.playCommand.addTarget { [weak self] _ in self?.playPause(); return .success }
        center.pauseCommand.addTarget { [weak self] _ in self?.playPause(); return .success }
        center.nextTrackCommand.addTarget { [weak self] _ in self?.next(); return .success }
        center.previousTrackCommand.addTarget { [weak self] _ in self?.previous(); return .success }
        center.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let self = self, let event = event as? MPChangePlaybackPositionCommandEvent else {
                return .commandFailed
            }
            self.seek(to: event.positionTime)
            return .success
        }
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
        UserDefaults.standard.set(isPlaying, forKey: "wasPlaying")
    }

    private func loadLastPosition(for song: Song) -> TimeInterval {
        let key = lastPositionKey(for: song)
        return UserDefaults.standard.double(forKey: key)
    }

    @objc private func playerDidFinishPlaying(_ notification: Notification) {
        guard let finishedItem = notification.object as? AVPlayerItem,
              finishedItem == player.currentItem else { return }

        if isRepeating {
            player.seek(to: CMTime(seconds: 0, preferredTimescale: 1)) { [weak self] _ in
                if self?.isPlaying == true {
                    self?.player.play()
                }
            }
        } else {
            next()
        }
    }

    func toggleRepeat() {
        isRepeating.toggle()
    }

    func switchToPlaylist(_ playlist: Playlist) {
        saveCurrentPosition()
        currentPlaylist = playlist
        // Remove duplicates while preserving order
        var seen = Set<String>()
        let uniqueSongs = playlist.songs.filter { song in
            if seen.contains(song.id) {
                return false
            } else {
                seen.insert(song.id)
                return true
            }
        }
        songs = uniqueSongs
        currentIndex = 0
        replaceCurrentSong()
    }

    // Helper method to add song to the current playlist without duplicates
    func addSongToCurrentPlaylist(_ song: Song) {
        guard var playlist = currentPlaylist else { return }
        if !playlist.songs.contains(where: { $0.id == song.id }) {
            playlist.songs.append(song)
            if let index = playlists.firstIndex(where: { $0.id == playlist.id }) {
                playlists[index] = playlist
                currentPlaylist = playlist
            }
        }
    }
    func seek(to time: TimeInterval) {
        let cmTime = CMTime(seconds: time, preferredTimescale: 1)
        player.seek(to: cmTime) { [weak self] _ in
            if self?.isPlaying == true {
                self?.player.play()
            }
        }
    }
    @objc private func handleBluetoothConnection(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
            return
        }

        if reason == .newDeviceAvailable {
            let session = AVAudioSession.sharedInstance()
            let hasBluetooth = session.currentRoute.outputs.contains { output in
                output.portType == .bluetoothA2DP || output.portType == .bluetoothLE || output.portType == .bluetoothHFP
            }

            if hasBluetooth && !isPlaying {
                isPlaying = true
                player.play()
                updateNowPlayingInfo()
            }
        }
    }
}
