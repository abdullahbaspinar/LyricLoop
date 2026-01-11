//
//  UserProgress.swift
//  LyricLoop
//
//  Created by Abdullah B on 15.11.2025.
//

import Foundation

struct UserProgress: Codable {
    var totalXP: Int = 0
    var currentLevel: Int = 1
    var streak: Int = 0
    var lastPlayDate: Date?
    var completedSections: [String: [String]] = [:] // songId: [sectionIds]
    var achievements: [String] = [] // Achievement IDs
    var hearts: Int = 20 // Kalp sayısı (max 20)
    var lastHeartRefillTime: Date? // Son kalp dolum zamanı
    var totalScore: Int = 0 // Total stars/score earned
    var sectionsCompletedInSession: Int = 0 // Sections completed in current session
    var perfectSections: Int = 0 // Sections completed with 3 stars
    
    var xpForNextLevel: Int {
        currentLevel * 500
    }
    
    mutating func addXP(_ amount: Int) {
        totalXP += amount
        while totalXP >= xpForNextLevel {
            totalXP -= xpForNextLevel
            currentLevel += 1
        }
    }
    
    mutating func completeSection(songId: String, sectionId: String) {
        if completedSections[songId] == nil {
            completedSections[songId] = []
        }
        if !completedSections[songId]!.contains(sectionId) {
            completedSections[songId]!.append(sectionId)
        }
    }
    
    func isSectionCompleted(songId: String, sectionId: String) -> Bool {
        return completedSections[songId]?.contains(sectionId) ?? false
    }
    
    func completionPercentage(for songId: String, totalSections: Int) -> Double {
        let completed = completedSections[songId]?.count ?? 0
        return totalSections > 0 ? Double(completed) / Double(totalSections) : 0.0
    }
}

struct GameFeedback {
    let isCorrect: Bool
    let message: String
}

struct SectionResult {
    let stars: Int
    let accuracy: Double
    let mistakes: Int
    let timeTaken: TimeInterval
}

