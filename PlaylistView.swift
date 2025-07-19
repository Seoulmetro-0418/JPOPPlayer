import SwiftUI
import UIKit

struct PlaylistView: View {
    @ObservedObject var audioManager: AudioManager
    @State private var selectedPlaylist: Playlist?
    @State private var newName: String = ""

    var body: some View {
        NavigationView {
            VStack {
                if let selected = selectedPlaylist {
                    List {
                        Section(header: Text(String(format: NSLocalizedString("songs_in_playlist", comment: ""), selected.name))) {
                            ForEach(selected.songs) { song in
                                Text(song.title)
                            }
                            .onDelete { indexSet in
                                selectedPlaylist?.songs.remove(atOffsets: indexSet)
                                saveChanges()
                            }
                            .onMove { indices, newOffset in
                                selectedPlaylist?.songs.move(fromOffsets: indices, toOffset: newOffset)
                                saveChanges()
                            }
                        }
                    }
                    .toolbar {
                        EditButton()
                    }

                    Button(NSLocalizedString("play_this_playlist", comment: "")) {
                        if let playlist = selectedPlaylist {
                            audioManager.switchToPlaylist(playlist)
                        }
                    }
                    .padding()
                }

                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    Text(NSLocalizedString("create_new_playlist", comment: ""))
                        .font(.headline)
                    TextField(NSLocalizedString("playlist_name", comment: ""), text: $newName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button(NSLocalizedString("create_playlist", comment: "")) {
                        guard !newName.isEmpty else { return }
                        let playlist = Playlist(id: UUID(), name: newName, songs: [])
                        audioManager.playlists.append(playlist)
                        selectedPlaylist = playlist
                        newName = ""
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                    .disabled(newName.isEmpty)
                }
                .padding()

                Divider()

                Text(NSLocalizedString("add_songs_to_playlist", comment: ""))
                    .font(.headline)
                    .padding(.top)

                List {
                    ForEach(SongLibrary.songs) { song in
                        Button(action: {
                            addSongToSelectedPlaylist(song)
                        }) {
                            HStack {
                                Text(song.title)
                                Spacer()
                                if selectedPlaylist?.songs.contains(where: { $0.id == song.id }) == true {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .disabled(selectedPlaylist == nil || selectedPlaylist!.songs.contains(where: { $0.id == song.id }))
                    }
                }

                Divider()

                Text(NSLocalizedString("your_playlists", comment: ""))
                    .font(.headline)
                    .padding(.top)

                List {
                    ForEach(audioManager.playlists) { playlist in
                        Button(action: {
                            selectedPlaylist = playlist
                        }) {
                            Text(playlist.name)
                                .fontWeight(playlist.id == selectedPlaylist?.id ? .bold : .regular)
                        }
                    }
                    .onDelete { indexSet in
                        audioManager.playlists.remove(atOffsets: indexSet)
                        if let selected = selectedPlaylist,
                           !audioManager.playlists.contains(where: { $0.id == selected.id }) {
                            selectedPlaylist = nil
                        }
                    }
                    .onMove { indices, newOffset in
                        audioManager.playlists.move(fromOffsets: indices, toOffset: newOffset)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Playlists")
        }
    }

    private func saveChanges() {
        guard let updated = selectedPlaylist else { return }
        if let index = audioManager.playlists.firstIndex(where: { $0.id == updated.id }) {
            audioManager.playlists[index] = updated
            audioManager.currentPlaylist = updated
        }
    }

    private func addSongToSelectedPlaylist(_ song: Song) {
        guard var playlist = selectedPlaylist else { return }
        if !playlist.songs.contains(where: { $0.id == song.title }) {
            playlist.songs.append(song)
            if let index = audioManager.playlists.firstIndex(where: { $0.id == playlist.id }) {
                audioManager.playlists[index] = playlist
                selectedPlaylist = playlist
                audioManager.currentPlaylist = playlist
            }
        }
    }
}

struct PlaylistView_Previews: PreviewProvider {
    static var previews: some View {
        PlaylistView(audioManager: AudioManager())
    }
}
