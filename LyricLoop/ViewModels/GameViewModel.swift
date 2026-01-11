//
//  GameViewModel.swift
//  LyricLoop
//
//  Created by Abdullah B on 15.11.2025.
//

import Foundation
import Combine
import AVFoundation

@MainActor
class GameViewModel: ObservableObject {
    @Published var currentSectionIndex: Int = 0
    @Published var currentBlankIndex: Int = 0
    @Published var filledBlanks: [Int: String] = [:]
    @Published var availableCandidates: [String] = []
    @Published var score: Int = 0
    @Published var hearts: Int = 20
    @Published var feedback: GameFeedback? = nil
    @Published var timeUntilNextHeart: TimeInterval? = nil
    @Published var showHeartPopup: Bool = false
    @Published var sectionResult: SectionResult? = nil
    @Published var isSectionComplete: Bool = false
    @Published var audioFinished: Bool = false // Şarkı bitti mi?
    
    let song: Song
    let audioService: AudioServiceProtocol
    let progressService: ProgressServiceProtocol
    let soundEffectService: SoundEffectServiceProtocol
    
    private var sectionStartTime: Date = Date()
    private var mistakes: Int = 0
    private var correctAnswers: Int = 0
    
    private var heartTimer: Timer?
    
    init(song: Song, audioService: AudioServiceProtocol, progressService: ProgressServiceProtocol, soundEffectService: SoundEffectServiceProtocol = SoundEffectService.shared) {
        self.song = song
        self.audioService = audioService
        self.progressService = progressService
        self.soundEffectService = soundEffectService
        
        // Kalpleri yükle ve timer başlat
        hearts = progressService.getHearts()
        startHeartTimer()
        
        setupCurrentSection(shouldPlay: false) // Init'te şarkıyı başlatma, sadece setup yap
    }
    
    private func startHeartTimer() {
        heartTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            // Kalp sayısını güncelle
            self.hearts = self.progressService.getHearts()
            
            // Sonraki kalp için kalan süreyi güncelle
            self.timeUntilNextHeart = self.progressService.getTimeUntilNextHeart()
        }
    }
    
    deinit {
        heartTimer?.invalidate()
    }
    
    var currentSection: LyricSection? {
        guard currentSectionIndex < song.sections.count else { return nil }
        return song.sections[currentSectionIndex]
    }
    
    var formattedLyricText: [(text: String, isBlank: Bool, isFilled: Bool, filledText: String?)] {
        guard let section = currentSection else { return [] }
        
        return section.tokens.enumerated().map { index, token in
            let isFilled = filledBlanks[index] != nil
            let filledText = filledBlanks[index]
            
            return (
                text: token.text,
                isBlank: token.isBlank,
                isFilled: isFilled,
                filledText: filledText
            )
        }
    }
    
    var progress: Double {
        guard let section = currentSection else { return 0.0 }
        let totalBlanks = section.missingTokenIndices.count
        guard totalBlanks > 0 else { return 1.0 }
        return Double(filledBlanks.count) / Double(totalBlanks)
    }
    
    func setupCurrentSection(shouldPlay: Bool = true) {
        guard let section = currentSection else { return }
        currentBlankIndex = 0
        filledBlanks = [:]
        availableCandidates = section.candidateWords
        sectionStartTime = Date()
        mistakes = 0
        correctAnswers = 0
        isSectionComplete = false
        audioFinished = false
        
        // Reset session counter when starting a new game
        if currentSectionIndex == 0 {
            var current = progressService.progress.value
            current.sectionsCompletedInSession = 0
            progressService.progress.send(current)
            progressService.saveProgress()
        }
        
        // Şarkıyı bu bölümün başlangıcından 1-2 saniye önce başlat, bitiminden 1-2 saniye sonra durdur
        if shouldPlay {
            startPlaying()
        }
    }
    
    func startPlaying() {
        guard let section = currentSection else { return }
        let startTime = max(0, section.startTime - 1.5) // 1.5 saniye önce başla
        // endTime zaten sözlerin bitiminden 1.5 saniye sonra ayarlanmış, ekstra eklemeye gerek yok
        let endTime = section.endTime > 0 ? section.endTime : nil
        
        audioFinished = false // Reset flag
        
        if let realAudioService = audioService as? RealAudioService {
            // Şarkı bitiş callback'i ayarla
            realAudioService.onAudioFinished = { [weak self] in
                DispatchQueue.main.async {
                    self?.audioFinished = true
                }
            }
            
            realAudioService.playFromTime(startTime, until: endTime)
        } else {
            audioService.play()
        }
    }
    
    func replayAudio() {
        audioFinished = false
        startPlaying()
    }
    
    func toggleHeartPopup() {
        showHeartPopup.toggle()
        if showHeartPopup {
            // Pause audio when popup opens
            audioService.pause()
        } else {
            // Resume audio when popup closes - continue from where it was
            if let realAudioService = audioService as? RealAudioService {
                // Get current time from progress
                guard let section = currentSection else { return }
                let currentProgress = realAudioService.progress.value
                let totalDuration = realAudioService.audioPlayer?.duration ?? 0
                let currentTime = currentProgress * totalDuration
                let endTime = section.endTime > 0 ? section.endTime + 1.5 : nil
                
                if currentTime > 0 && currentTime < totalDuration {
                    realAudioService.playFromTime(currentTime, until: endTime)
                } else {
                    startPlaying()
                }
            }
        }
    }
    
    func selectCandidate(_ word: String) {
        // Check hearts - can't play if 0 hearts
        guard hearts > 0 else {
            feedback = GameFeedback(isCorrect: false, message: "No hearts! Please wait.")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                self?.feedback = nil
            }
            return
        }
        
        guard let section = currentSection else { return }
        guard let blankIndex = getNextBlankIndex() else { return }
        
        let correctWord = section.tokens[section.missingTokenIndices[blankIndex]].text
            .trimmingCharacters(in: .punctuationCharacters)
            .lowercased()
        let selectedWord = word.lowercased()
        
        if correctWord == selectedWord {
            // Correct answer
            filledBlanks[section.missingTokenIndices[blankIndex]] = word
            correctAnswers += 1
            score += 10
            // Add to total score
            progressService.addScore(10)
            feedback = GameFeedback(isCorrect: true, message: "Correct!")
            soundEffectService.playCorrectSound()
            
            // Check if section is complete
            if filledBlanks.count == section.missingTokenIndices.count {
                completeSection()
            }
        } else {
            // Wrong answer - use heart immediately
            mistakes += 1
            // Use heart immediately (don't wait for section to end)
            let heartUsed = progressService.useHeart()
            // Always update hearts from service to ensure sync
            hearts = progressService.getHearts()
            
            if !heartUsed {
                // No hearts, can't play
                feedback = GameFeedback(isCorrect: false, message: "No hearts! Please wait.")
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                    self?.feedback = nil
                }
                return
            }
            feedback = GameFeedback(isCorrect: false, message: "Try again!")
            soundEffectService.playWrongSound()
        }
        
        // Clear feedback after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.feedback = nil
        }
    }
    
    private func getNextBlankIndex() -> Int? {
        guard let section = currentSection else { return nil }
        let filledIndices = Set(filledBlanks.keys)
        let nextBlank = section.missingTokenIndices.firstIndex { !filledIndices.contains($0) }
        return nextBlank
    }
    
    private func completeSection() {
        guard let section = currentSection else { return }
        
        let timeTaken = Date().timeIntervalSince(sectionStartTime)
        let totalBlanks = section.missingTokenIndices.count
        let accuracy = totalBlanks > 0 ? Double(correctAnswers) / Double(totalBlanks + mistakes) : 1.0
        
        // Calculate stars (1-3)
        var stars = 1
        if accuracy >= 0.9 && mistakes == 0 {
            stars = 3
        } else if accuracy >= 0.7 && mistakes <= 1 {
            stars = 2
        }
        
        sectionResult = SectionResult(
            stars: stars,
            accuracy: accuracy,
            mistakes: mistakes,
            timeTaken: timeTaken
        )
        
        // Save progress with stars
        progressService.completeSection(songId: song.id.uuidString, sectionId: section.id.uuidString, stars: stars)
        progressService.addXP(stars * 50) // Award XP based on stars
        progressService.updateStreak()
        
        // Check for completionist achievement (all sections of song completed)
        let allSectionsCompleted = song.sections.allSatisfy { section in
            progressService.progress.value.completedSections[song.id.uuidString]?.contains(section.id.uuidString) ?? false
        }
        if allSectionsCompleted {
            progressService.unlockAchievement(.completionist)
        }
        
        // Play completion sound
        soundEffectService.playCompletionSound()
        
        // Şarkıyı tamamen durdur (bölüm bitti)
        audioService.stop()
        audioFinished = true
        isSectionComplete = true
    }
    
    func goToNextSection() {
        if currentSectionIndex < song.sections.count - 1 {
            // Önce şarkıyı durdur
            audioService.stop()
            audioFinished = false
            
            // Sonra yeni bölüme geç ve şarkıyı başlat
            currentSectionIndex += 1
            setupCurrentSection(shouldPlay: true)
        }
    }
    
    func restartSection() {
        // Önce şarkıyı durdur
        audioService.stop()
        audioFinished = false
        
        // Sonra bölümü yeniden başlat
        setupCurrentSection(shouldPlay: true)
    }
    
    func backToSong() {
        audioService.stop()
        audioFinished = false
    }
}

