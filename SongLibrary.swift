import Foundation

struct Song {
    let title: String
    let artist: String
    let fileName: String
    let albumImageName: String
    let trackNumber: Int
    let lyrics: [(time: TimeInterval, text: String)]
}

struct SongLibrary {
    static var songs: [Song] {
        let preferredLang = Locale.preferredLanguages.first ?? "ja"
        if preferredLang.starts(with: "ko") {
            return SongLibrary_ko.songs
        } else {
            return SongLibrary_ja.songs
        }
    }
}
