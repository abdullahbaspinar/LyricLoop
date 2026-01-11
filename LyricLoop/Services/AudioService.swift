//
//  AudioService.swift
//  LyricLoop
//
//  Created by Abdullah B on 15.11.2025.
//

import Foundation
import Combine
import AVFoundation

protocol AudioServiceProtocol {
    var progress: CurrentValueSubject<Double, Never> { get }
    var isPlaying: Bool { get }
    
    func play()
    func pause()
    func stop()
    func seek(to progress: Double)
}

// Gerçek müzik dosyası çalan servis
class RealAudioService: AudioServiceProtocol, ObservableObject {
    var progress = CurrentValueSubject<Double, Never>(0.0)
    var isPlaying: Bool = false
    
    var audioPlayer: AVAudioPlayer? // Made internal for access
    private var updateTimer: Timer?
    private let audioFileName: String?
    
    init(audioFileName: String?, duration: TimeInterval) {
        self.audioFileName = audioFileName
        setupAudioPlayer()
    }
    
    private func setupAudioPlayer() {
        guard let audioFileName = audioFileName else {
            // Müzik dosyası yoksa MockAudioService gibi davran
            return
        }
        
        guard let url = Bundle.main.url(forResource: audioFileName, withExtension: nil) ??
                       Bundle.main.url(forResource: audioFileName.replacingOccurrences(of: ".mp3", with: ""), withExtension: "mp3") ??
                       Bundle.main.url(forResource: audioFileName.replacingOccurrences(of: ".m4a", with: ""), withExtension: "m4a") else {
            print("Müzik dosyası bulunamadı: \(audioFileName)")
            print("Müzik dosyalarını Xcode'da Assets klasörüne veya doğrudan projeye ekleyin")
            return
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.numberOfLoops = 0
        } catch {
            print("❌ Müzik yüklenemedi: \(error.localizedDescription)")
        }
    }
    
    func play() {
        playFromTime(0)
    }
    
    
    func pause() {
        audioPlayer?.pause()
        isPlaying = false
        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    func stop() {
        audioPlayer?.stop()
        audioPlayer?.currentTime = 0
        isPlaying = false
        progress.send(0.0)
        updateTimer?.invalidate()
        updateTimer = nil
        endTime = nil
        onAudioFinished = nil
    }
    
    func seek(to progress: Double) {
        guard let player = audioPlayer else { return }
        let time = progress * player.duration
        player.currentTime = time
        self.progress.send(progress)
    }
    
    private var endTime: TimeInterval?
    var onAudioFinished: (() -> Void)? // Şarkı bittiğinde çağrılacak callback
    
    func playFromTime(_ time: TimeInterval, until endTime: TimeInterval? = nil) {
        self.endTime = endTime
        if let player = audioPlayer {
            // Gerçek müzik dosyası varsa
            player.currentTime = max(0, min(time, player.duration))
            player.play()
            isPlaying = true
            startProgressTimer()
        } else {
            // Müzik dosyası yoksa, sadece progress bar'ı simüle et
            isPlaying = true
            startProgressTimer()
        }
    }
    
    private func startProgressTimer() {
        updateTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if let player = self.audioPlayer {
                if player.isPlaying {
                    // Eğer endTime belirtilmişse ve o zamana ulaşıldıysa durdur
                    if let endTime = self.endTime, player.currentTime >= endTime {
                        self.stop()
                        self.onAudioFinished?()
                        return
                    }
                    
                    let currentProgress = player.duration > 0 ? player.currentTime / player.duration : 0.0
                    self.progress.send(currentProgress)
                } else {
                    // Müzik bitti veya durdu
                    if self.endTime == nil {
                        self.stop()
                    } else {
                        self.onAudioFinished?()
                    }
                }
            } else {
                // Mock mode: sadece progress simüle et
                let currentProgress = self.progress.value + 0.01
                if currentProgress >= 1.0 {
                    self.stop()
                } else {
                    self.progress.send(currentProgress)
                }
            }
        }
    }
    
    deinit {
        audioPlayer?.stop()
        updateTimer?.invalidate()
    }
}

// Eski MockAudioService - geriye dönük uyumluluk için
class MockAudioService: AudioServiceProtocol, ObservableObject {
    var progress = CurrentValueSubject<Double, Never>(0.0)
    var isPlaying: Bool = false
    
    private var timer: Timer?
    private let duration: TimeInterval
    private var currentTime: TimeInterval = 0
    
    init(duration: TimeInterval) {
        self.duration = duration
    }
    
    func play() {
        guard !isPlaying else { return }
        isPlaying = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.currentTime += 0.1
            
            if self.currentTime >= self.duration {
                self.stop()
            } else {
                self.progress.send(self.currentTime / self.duration)
            }
        }
    }
    
    func pause() {
        isPlaying = false
        timer?.invalidate()
        timer = nil
    }
    
    func stop() {
        isPlaying = false
        currentTime = 0
        progress.send(0.0)
        timer?.invalidate()
        timer = nil
    }
    
    func seek(to progress: Double) {
        currentTime = progress * duration
        self.progress.send(progress)
    }
    
    deinit {
        timer?.invalidate()
    }
}

