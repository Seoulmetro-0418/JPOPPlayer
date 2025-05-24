//
//  Song.swift
//  JPOPPlayer
//
//  Created by Hyunjun Kim on 5/17/25.
//


import Foundation

struct Song {
    let title: String
    let artist: String
    let fileName: String       // 예: "song1"
    let albumImageName: String // 예: "album1"
    let lyrics: [(time: TimeInterval, text: String)]
}