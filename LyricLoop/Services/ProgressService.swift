//
//  ProgressService.swift
//  LyricLoop
//
//  Created by Abdullah B on 15.11.2025.
//

import Foundation
import Combine

protocol ProgressServiceProtocol {
    var progress: CurrentValueSubject<UserProgress, Never> { get }
    
    func loadProgress()
    func saveProgress()
    func addXP(_ amount: Int)
    func addScore(_ amount: Int)
    func completeSection(songId: String, sectionId: String, stars: Int)
    func updateStreak()
    func getHearts() -> Int
    func useHeart() -> Bool
    func getTimeUntilNextHeart() -> TimeInterval?
    func checkAchievements() -> [Achievement]
    func unlockAchievement(_ achievement: Achievement)
}

class ProgressService: ProgressServiceProtocol, ObservableObject {
    var progress = CurrentValueSubject<UserProgress, Never>(UserProgress())
    
    private let progressKey = "lyricLoop_userProgress"
    
    init() {
        loadProgress()
    }
    
    func loadProgress() {
        if let data = UserDefaults.standard.data(forKey: progressKey),
           let decoded = try? JSONDecoder().decode(UserProgress.self, from: data) {
            progress.send(decoded)
        } else {
            progress.send(UserProgress())
        }
    }
    
    func saveProgress() {
        if let encoded = try? JSONEncoder().encode(progress.value) {
            UserDefaults.standard.set(encoded, forKey: progressKey)
        }
    }
    
    func addXP(_ amount: Int) {
        var current = progress.value
        let oldLevel = current.currentLevel
        current.addXP(amount)
        progress.send(current)
        saveProgress()
        
        // Check for level up achievements
        if current.currentLevel >= 5 && oldLevel < 5 {
            unlockAchievement(.levelUp)
        }
        if current.currentLevel >= 10 && oldLevel < 10 {
            unlockAchievement(.masterLearner)
        }
        
        checkAchievements()
    }
    
    func addScore(_ amount: Int) {
        var current = progress.value
        let oldScore = current.totalScore
        current.totalScore += amount
        progress.send(current)
        saveProgress()
        
        // Check for star achievements
        if current.totalScore >= 100 && oldScore < 100 {
            unlockAchievement(.starCollector)
        }
        if current.totalScore >= 500 && oldScore < 500 {
            unlockAchievement(.starMaster)
        }
        
        checkAchievements()
    }
    
    func completeSection(songId: String, sectionId: String, stars: Int = 0) {
        var current = progress.value
        current.completeSection(songId: songId, sectionId: sectionId)
        current.sectionsCompletedInSession += 1
        
        if stars == 3 {
            current.perfectSections += 1
            unlockAchievement(.perfectSection)
        }
        
        // Check for speed demon achievement
        if current.sectionsCompletedInSession >= 5 {
            unlockAchievement(.speedDemon)
        }
        
        progress.send(current)
        saveProgress()
        checkAchievements()
    }
    
    func checkAchievements() -> [Achievement] {
        loadProgress() // Ensure we have latest data
        var current = progress.value
        var newlyUnlocked: [Achievement] = []
        
        for achievement in Achievement.allCases {
            // Skip if already unlocked
            if current.achievements.contains(achievement.rawValue) {
                continue
            }
            
            // Check if achievement should be unlocked
            if achievement.checkUnlock(
                progress: current,
                totalScore: current.totalScore,
                sectionsCompletedInSession: current.sectionsCompletedInSession
            ) {
                unlockAchievement(achievement)
                newlyUnlocked.append(achievement)
            }
        }
        
        return newlyUnlocked
    }
    
    func unlockAchievement(_ achievement: Achievement) {
        var current = progress.value
        if !current.achievements.contains(achievement.rawValue) {
            current.achievements.append(achievement.rawValue)
            progress.send(current)
            saveProgress()
        }
    }
    
    func updateStreak() {
        var current = progress.value
        let calendar = Calendar.current
        let today = Date()
        
        if let lastDate = current.lastPlayDate {
            if calendar.isDateInToday(lastDate) {
                // Already played today, no change
            } else if calendar.dateInterval(of: .day, for: lastDate)?.contains(today) == false {
                let daysSince = calendar.dateComponents([.day], from: lastDate, to: today).day ?? 0
                if daysSince == 1 {
                    // Consecutive day
                    current.streak += 1
                } else {
                    // Streak broken
                    current.streak = 1
                }
            }
        } else {
            // First time playing
            current.streak = 1
        }
        
        current.lastPlayDate = today
        progress.send(current)
        saveProgress()
        
        // Check for first steps achievement
        if current.completedSections.values.reduce(0, { $0 + $1.count }) > 0 {
            unlockAchievement(.firstSteps)
        }
        
        // Check for on fire achievement
        if current.streak >= 7 {
            unlockAchievement(.onFire)
        }
        
        checkAchievements()
    }
    
    func getHearts() -> Int {
        // First load from UserDefaults
        loadProgress()
        var current = progress.value
        
        // İlk başlatma - eğer hiç kalp yoksa 20 ver
        if current.hearts == 0 && current.lastHeartRefillTime == nil {
            current.hearts = 20
            current.lastHeartRefillTime = Date()
            progress.send(current)
            saveProgress()
            return 20
        }
        
        // Kalp dolumu kontrolü (her 1 dakikada 1 kalp)
        if let lastRefill = current.lastHeartRefillTime {
            let timeSinceLastRefill = Date().timeIntervalSince(lastRefill)
            let secondsPassed = timeSinceLastRefill
            let minutesPassed = Int(secondsPassed / 60)
            
            if minutesPassed > 0 && current.hearts < 20 {
                let heartsToAdd = min(minutesPassed, 20 - current.hearts)
                current.hearts += heartsToAdd
                // Update last refill time but keep track of remaining seconds
                let remainingSeconds = secondsPassed.truncatingRemainder(dividingBy: 60.0)
                current.lastHeartRefillTime = Date().addingTimeInterval(-remainingSeconds)
                progress.send(current)
                saveProgress()
            }
        } else {
            // Eğer lastHeartRefillTime yoksa ama hearts varsa, şimdi başlat
            if current.hearts > 0 {
                current.lastHeartRefillTime = Date()
                progress.send(current)
                saveProgress()
            }
        }
        
        return current.hearts
    }
    
    func useHeart() -> Bool {
        var current = progress.value
        if current.hearts > 0 {
            current.hearts -= 1
            if current.lastHeartRefillTime == nil {
                current.lastHeartRefillTime = Date()
            }
            progress.send(current)
            saveProgress()
            
            // Check for heart breaker achievement
            if current.hearts == 0 {
                unlockAchievement(.heartBreaker)
            }
            
            return true
        }
        return false
    }
    
    func getTimeUntilNextHeart() -> TimeInterval? {
        let current = progress.value
        guard current.hearts < 20, let lastRefill = current.lastHeartRefillTime else {
            return nil
        }
        
        let timeSinceLastRefill = Date().timeIntervalSince(lastRefill)
        let secondsUntilNext = 60.0 - (timeSinceLastRefill.truncatingRemainder(dividingBy: 60.0))
        
        return secondsUntilNext > 0 ? secondsUntilNext : nil
    }
    
    // Önceki 3 şarkıdan (Skyfall, Back to Black, Demons) kazanılan toplam XP'yi hesapla
    // Her şarkıda 5 bölüm var, her bölüm maksimum 3 yıldız = 150 XP
    // Toplam max XP = 5 * 150 = 750 XP per şarkı
    // Önceki 3 şarkıdan toplam max XP = 3 * 750 = 2250 XP
    // %70'i = 1575 XP
    // 
    // Not: Gerçek XP'yi hesaplamak için UserProgress'te her bölüm için kazanılan XP saklanmalı
    // Şimdilik, her tamamlanan bölüm için ortalama 100 XP varsayıyoruz (2 yıldız ortalaması)
    // Bu yaklaşık bir tahmin - gerçek değer biraz farklı olabilir
    func getXPFromInitialSongs() -> Int {
        let current = progress.value
        let initialSongIds = SongRepository.initialSongsIds.map { $0.uuidString }
        
        var totalXP = 0
        
        // Her şarkı için tamamlanan bölümleri kontrol et
        for songId in initialSongIds {
            if let completedSections = current.completedSections[songId] {
                // Her tamamlanan bölüm için ortalama 100 XP varsayıyoruz (2 yıldız ortalaması)
                // Gerçekte: 1 yıldız = 50 XP, 2 yıldız = 100 XP, 3 yıldız = 150 XP
                // Ortalama: (50 + 100 + 150) / 3 = 100 XP
                totalXP += completedSections.count * 100
            }
        }
        
        return totalXP
    }
    
    // Kilit açılma koşulu: Önceki 3 şarkıdan %70 XP kazanılmış mı?
    // Max XP = 2250, %70 = 1575 XP
    func isUnlocked(songId: UUID) -> Bool {
        // İlk 3 şarkı her zaman açık
        if SongRepository.initialSongsIds.contains(songId) {
            return true
        }
        
        // Diğer şarkılar için %70 koşulu
        let xpFromInitial = getXPFromInitialSongs()
        let requiredXP = 1575 // 2250 * 0.7 = 1575
        
        return xpFromInitial >= requiredXP
    }
}

