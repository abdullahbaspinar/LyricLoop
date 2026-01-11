//
//  Song.swift
//  LyricLoop
//
//  Created by Abdullah B on 15.11.2025.
//

import Foundation

struct Song: Identifiable, Hashable {
    let id: UUID
    let title: String
    let artist: String
    let difficulty: Difficulty
    let coverImageName: String
    let duration: TimeInterval
    let audioFileName: String? // Optional: müzik dosyası adı (örn: "song1.mp3")
    let sections: [LyricSection]
    
    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return "\(minutes):\(String(format: "%02d", seconds))"
    }
}

