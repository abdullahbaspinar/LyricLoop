//
//  SoundEffectService.swift
//  LyricLoop
//
//  Created by Abdullah B on 15.11.2025.
//

import Foundation
import AVFoundation
import AudioToolbox

protocol SoundEffectServiceProtocol {
    func playCorrectSound()
    func playWrongSound()
    func playCompletionSound()
    func playButtonTap()
    func setSoundEffectsEnabled(_ enabled: Bool)
}

class SoundEffectService: SoundEffectServiceProtocol {
    private var soundEffectsEnabled: Bool = true
    
    init() {
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    func setSoundEffectsEnabled(_ enabled: Bool) {
        soundEffectsEnabled = enabled
    }
    
    func playCorrectSound() {
        guard soundEffectsEnabled else { return }
        // High-pitched success sound
        AudioServicesPlaySystemSound(1057) // System success sound
    }
    
    func playWrongSound() {
        guard soundEffectsEnabled else { return }
        // Low-pitched error sound
        AudioServicesPlaySystemSound(1053) // System error sound
    }
    
    func playCompletionSound() {
        guard soundEffectsEnabled else { return }
        // Play success sound sequence
        AudioServicesPlaySystemSound(1057)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            AudioServicesPlaySystemSound(1057)
        }
    }
    
    func playButtonTap() {
        guard soundEffectsEnabled else { return }
        // Light tap sound
        AudioServicesPlaySystemSound(1104) // System tap sound
    }
}

// Singleton instance for easy access
extension SoundEffectService {
    static let shared = SoundEffectService()
}

