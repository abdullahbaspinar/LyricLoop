//
//  SongDetailViewModel.swift
//  LyricLoop
//
//  Created by Abdullah B on 15.11.2025.
//

import Foundation
import Combine

@MainActor
class SongDetailViewModel: ObservableObject {
    @Published var song: Song?
    @Published var userProgress: UserProgress = UserProgress()
    @Published var completionPercentage: Double = 0.0
    
    let songRepository: SongRepositoryProtocol
    let progressService: ProgressServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(songId: UUID, songRepository: SongRepositoryProtocol, progressService: ProgressServiceProtocol) {
        self.songRepository = songRepository
        self.progressService = progressService
        
        loadSong(id: songId)
        observeProgress()
    }
    
    private func loadSong(id: UUID) {
        song = songRepository.getSong(by: id)
        updateCompletionPercentage()
    }
    
    private func observeProgress() {
        progressService.progress
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateCompletionPercentage()
            }
            .store(in: &cancellables)
    }
    
    private func updateCompletionPercentage() {
        guard let song = song else { return }
        let songId = song.id.uuidString
        completionPercentage = userProgress.completionPercentage(for: songId, totalSections: song.sections.count)
    }
    
    func isSectionCompleted(_ sectionId: UUID) -> Bool {
        guard let song = song else { return false }
        return userProgress.isSectionCompleted(songId: song.id.uuidString, sectionId: sectionId.uuidString)
    }
    
    var completedSectionsCount: Int {
        guard let song = song else { return 0 }
        let songId = song.id.uuidString
        return userProgress.completedSections[songId]?.count ?? 0
    }
    
    var totalSectionsCount: Int {
        return song?.sections.count ?? 0
    }
    
    var isLocked: Bool {
        guard let song = song else { return false }
        if let progressService = progressService as? ProgressService {
            return !progressService.isUnlocked(songId: song.id)
        }
        return false
    }
    
    var xpProgressForUnlock: (current: Int, required: Int) {
        if let progressService = progressService as? ProgressService {
            let current = progressService.getXPFromInitialSongs()
            let required = 1575 // 2250 * 0.7
            return (current, required)
        }
        return (0, 1575)
    }
}

