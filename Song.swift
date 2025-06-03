import Foundation

struct Song {
    let title: String
    let artist: String
    let fileName: String
    let albumImageName: String
    let trackNumber: Int
    let lyrics: [(time: TimeInterval, text: String)]
}
