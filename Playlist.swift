import Foundation

struct Playlist: Identifiable {
    let id: UUID
    var name: String
    var songs: [Song]
}
