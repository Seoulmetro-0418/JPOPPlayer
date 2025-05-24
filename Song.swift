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
    let fileName: String
    let albumImageName: String
    let lyrics: [(time: TimeInterval, text: String)]
}
