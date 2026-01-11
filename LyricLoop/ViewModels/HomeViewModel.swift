//
//  HomeViewModel.swift
//  LyricLoop
//
//  Created by Abdullah B on 15.11.2025.
//

import Foundation
import Combine

@MainActor
class HomeViewModel: ObservableObject {
    @Published var songs: [Song] = []
    @Published var filteredSongs: [Song] = []
    @Published var selectedDifficulty: Difficulty? = nil
    @Published var searchText: String = ""
    @Published var userProgress: UserProgress = UserProgress()
    
    let songRepository: SongRepositoryProtocol
    let progressService: ProgressServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(songRepository: SongRepositoryProtocol, progressService: ProgressServiceProtocol) {
        self.songRepository = songRepository
        self.progressService = progressService
        
        loadSongs()
        observeProgress()
    }
    
    private func loadSongs() {
        songs = songRepository.getAllSongs()
        applyFilters()
    }
    
    private func observeProgress() {
        progressService.progress
            .receive(on: DispatchQueue.main)
            .assign(to: &$userProgress)
    }
    
    func selectDifficulty(_ difficulty: Difficulty?) {
        selectedDifficulty = difficulty
        applyFilters()
    }
    
    func applyFilters() {
        var filtered = songRepository.getSongs(by: selectedDifficulty)
        
        if !searchText.isEmpty {
            filtered = filtered.filter { song in
                song.title.localizedCaseInsensitiveContains(searchText) ||
                song.artist.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // If "All" is selected, sort by difficulty (Beginner -> Intermediate -> Advanced)
        if selectedDifficulty == nil {
            filtered = filtered.sorted { $0.difficulty.order < $1.difficulty.order }
        }
        
        filteredSongs = filtered
    }
    
    func getGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        default: return "Good evening"
        }
    }
    
    func isSongLocked(_ song: Song) -> Bool {
        if let progressService = progressService as? ProgressService {
            return !progressService.isUnlocked(songId: song.id)
        }
        return false
    }
    
    func getXPProgressForUnlock() -> (current: Int, required: Int) {
        if let progressService = progressService as? ProgressService {
            let current = progressService.getXPFromInitialSongs()
            let required = 1575 // 2250 * 0.7
            return (current, required)
        }
        return (0, 1575)
    }
}

