//
//  Achievement.swift
//  LyricLoop
//
//  Created by Abdullah B on 15.11.2025.
//

import Foundation

enum Achievement: String, Codable, CaseIterable {
    case firstSteps = "first_steps"
    case starCollector = "star_collector"
    case starMaster = "star_master"
    case onFire = "on_fire"
    case masterLearner = "master_learner"
    case perfectSection = "perfect_section"
    case speedDemon = "speed_demon"
    case heartBreaker = "heart_breaker"
    case completionist = "completionist"
    case levelUp = "level_up"
    
    var id: String {
        return rawValue
    }
    
    var title: String {
        switch self {
        case .firstSteps: return "First Steps"
        case .starCollector: return "Star Collector"
        case .starMaster: return "Star Master"
        case .onFire: return "On Fire"
        case .masterLearner: return "Master Learner"
        case .perfectSection: return "Perfect Section"
        case .speedDemon: return "Speed Demon"
        case .heartBreaker: return "Heart Breaker"
        case .completionist: return "Completionist"
        case .levelUp: return "Level Up"
        }
    }
    
    var description: String {
        switch self {
        case .firstSteps: return "Complete your first section"
        case .starCollector: return "Earn 100 stars (score)"
        case .starMaster: return "Earn 500 stars (score)"
        case .onFire: return "Maintain a 7-day streak"
        case .masterLearner: return "Reach level 10"
        case .perfectSection: return "Complete a section with 3 stars"
        case .speedDemon: return "Complete 5 sections in one session"
        case .heartBreaker: return "Use all 20 hearts"
        case .completionist: return "Complete all sections of a song"
        case .levelUp: return "Reach level 5"
        }
    }
    
    var icon: String {
        switch self {
        case .firstSteps: return "trophy.fill"
        case .starCollector: return "star.fill"
        case .starMaster: return "star.circle.fill"
        case .onFire: return "flame.fill"
        case .masterLearner: return "graduationcap.fill"
        case .perfectSection: return "sparkles"
        case .speedDemon: return "bolt.fill"
        case .heartBreaker: return "heart.slash.fill"
        case .completionist: return "checkmark.seal.fill"
        case .levelUp: return "arrow.up.circle.fill"
        }
    }
    
    var color: String {
        switch self {
        case .firstSteps: return "warning"
        case .starCollector: return "warning"
        case .starMaster: return "warning"
        case .onFire: return "error"
        case .masterLearner: return "primaryPurple"
        case .perfectSection: return "accent"
        case .speedDemon: return "accent"
        case .heartBreaker: return "error"
        case .completionist: return "success"
        case .levelUp: return "accent"
        }
    }
    
    func checkUnlock(progress: UserProgress, totalScore: Int, sectionsCompletedInSession: Int) -> Bool {
        switch self {
        case .firstSteps:
            return progress.completedSections.values.reduce(0) { $0 + $1.count } > 0
        case .starCollector:
            return progress.totalScore >= 100
        case .starMaster:
            return progress.totalScore >= 500
        case .onFire:
            return progress.streak >= 7
        case .masterLearner:
            return progress.currentLevel >= 10
        case .perfectSection:
            // This should be checked when a section is completed with 3 stars
            return progress.perfectSections > 0
        case .speedDemon:
            return progress.sectionsCompletedInSession >= 5
        case .heartBreaker:
            return progress.hearts == 0 && progress.lastHeartRefillTime != nil
        case .completionist:
            // Check if all sections of any song are completed
            return false // Will be checked manually
        case .levelUp:
            return progress.currentLevel >= 5
        }
    }
}

