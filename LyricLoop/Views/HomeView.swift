//
//  HomeView.swift
//  LyricLoop
//
//  Created by Abdullah B on 15.11.2025.
//

import SwiftUI
import UIKit

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    @State private var selectedSong: Song?
    @State private var hearts: Int = 20
    @State private var timeUntilNextHeart: TimeInterval? = nil
    @State private var showHeartPopup: Bool = false
    @State private var heartTimer: Timer?
    @State private var showLockedSongAlert: Bool = false
    @State private var lockedSongXPInfo: (current: Int, required: Int) = (0, 1575)
    
    init(viewModel: HomeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(viewModel.getGreeting() + ", Abdullah")
                                    .font(.appHeadline)
                                    .foregroundColor(AppColor.textPrimary)
                                
                                HStack {
                                    Text("Level \(viewModel.userProgress.currentLevel)")
                                        .font(.appSubheadline)
                                        .foregroundColor(AppColor.textSecondary)
                                    
                                    Text("·")
                                        .foregroundColor(AppColor.textTertiary)
                                    
                                    Text("\(viewModel.userProgress.totalXP) XP")
                                        .font(.appSubheadline)
                                        .foregroundColor(AppColor.textSecondary)
                                }
                            }
                            
                            Spacer()
                            
                            // Hearts (clickable - shows popup)
                            Button(action: {
                                showHeartPopup = true
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "heart.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(hearts > 0 ? AppColor.error : AppColor.textTertiary)
                                    Text("\(hearts)/20")
                                        .font(.appBodyBold)
                                        .foregroundColor(AppColor.textPrimary)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        
                        // Search Bar
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(AppColor.textSecondary)
                            TextField("Search songs...", text: $viewModel.searchText)
                                .font(.appBody)
                                .foregroundColor(AppColor.textPrimary)
                                .onChange(of: viewModel.searchText) { _, _ in
                                    viewModel.applyFilters()
                                }
                        }
                        .padding()
                        .background(AppColor.cardBackground)
                        .cornerRadius(12)
                        .padding(.horizontal, 20)
                        
                        // Difficulty Filter
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                FilterChip(
                                    title: "All",
                                    isSelected: viewModel.selectedDifficulty == nil
                                ) {
                                    viewModel.selectDifficulty(nil)
                                }
                                
                                ForEach(Difficulty.allCases) { difficulty in
                                    FilterChip(
                                        title: difficulty.rawValue,
                                        isSelected: viewModel.selectedDifficulty == difficulty
                                    ) {
                                        viewModel.selectDifficulty(difficulty)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // Song List
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.filteredSongs.filter { $0.audioFileName != nil }) { song in
                                SongCard(
                                    song: song,
                                    progress: viewModel.userProgress,
                                    isLocked: viewModel.isSongLocked(song)
                                ) {
                                    if viewModel.isSongLocked(song) {
                                        lockedSongXPInfo = viewModel.getXPProgressForUnlock()
                                        showLockedSongAlert = true
                                    } else {
                                        selectedSong = song
                                    }
                                }
                            }
                            
                            // Coming soon songs message
                            if viewModel.filteredSongs.filter({ $0.audioFileName == nil }).isEmpty == false {
                                VStack(spacing: 16) {
                                    Text("Coming Soon")
                                        .font(.appHeadline)
                                        .foregroundColor(AppColor.textSecondary)
                                        .padding(.top, 20)
                                    
                                    Text("More songs will be added very soon!")
                                        .font(.appBody)
                                        .foregroundColor(AppColor.textTertiary)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 40)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationDestination(item: $selectedSong) { song in
                SongDetailView(
                    viewModel: SongDetailViewModel(
                        songId: song.id,
                        songRepository: viewModel.songRepository,
                        progressService: viewModel.progressService
                    )
                )
            }
            .overlay {
                // Heart Popup
                if showHeartPopup {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showHeartPopup = false
                        }
                    
                    VStack(spacing: 20) {
                        Text("Hearts")
                            .font(.appHeadline)
                            .foregroundColor(AppColor.textPrimary)
                        
                        HStack(spacing: 8) {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 24))
                                .foregroundColor(AppColor.error)
                            Text("\(hearts)/20")
                                .font(.appTitle)
                                .foregroundColor(AppColor.textPrimary)
                        }
                        
                        if let timeLeft = timeUntilNextHeart, hearts < 20 {
                            VStack(spacing: 8) {
                                Text("Next Heart")
                                    .font(.appCaption)
                                    .foregroundColor(AppColor.textSecondary)
                                Text("\(Int(timeLeft))s")
                                    .font(.appHeadline)
                                    .foregroundColor(AppColor.accent)
                            }
                        } else if hearts >= 20 {
                            Text("Full Hearts!")
                                .font(.appBody)
                                .foregroundColor(AppColor.textSecondary)
                        }
                        
                        Button(action: {
                            showHeartPopup = false
                        }) {
                            Text("Close")
                                .font(.appBodyBold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(AppColor.primaryGradient)
                                .cornerRadius(12)
                        }
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(AppColor.cardBackground)
                            .shadow(radius: 20)
                    )
                    .padding(.horizontal, 40)
                }
            }
            .alert("Song Locked", isPresented: $showLockedSongAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("You need to complete 70% of the first 3 songs to unlock this song.\n\nCurrent Progress: \(lockedSongXPInfo.current) / \(lockedSongXPInfo.required) XP\n\nKeep playing the first 3 songs to unlock more!")
            }
        }
        .onAppear {
            // Load hearts immediately
            hearts = viewModel.progressService.getHearts()
            timeUntilNextHeart = viewModel.progressService.getTimeUntilNextHeart()
            
            // Start timer to update hearts every second
            heartTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                hearts = viewModel.progressService.getHearts()
                timeUntilNextHeart = viewModel.progressService.getTimeUntilNextHeart()
            }
        }
        .onDisappear {
            heartTimer?.invalidate()
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.appBody)
                .foregroundColor(isSelected ? .white : AppColor.textSecondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Group {
                        if isSelected {
                            Capsule()
                                .fill(AppColor.primaryGradient)
                        } else {
                            Capsule()
                                .fill(AppColor.cardBackground)
                        }
                    }
                )
        }
    }
}

struct SongCard: View {
    let song: Song
    let progress: UserProgress
    let isLocked: Bool
    let action: () -> Void
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    private var coverSize: CGFloat {
        horizontalSizeClass == .regular ? 60 : 80 // Tablet için daha küçük
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Cover Art
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(AppColor.cardGradient)
                        .frame(width: coverSize, height: coverSize)
                        .overlay(
                            Group {
                                if UIImage(named: song.coverImageName) != nil {
                                    Image(song.coverImageName)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                } else {
                                    Image(systemName: song.coverImageName)
                                        .font(.system(size: horizontalSizeClass == .regular ? 24 : 32))
                                        .foregroundStyle(AppColor.primaryGradient)
                                }
                            }
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .opacity(isLocked ? 0.5 : 1.0)
                    
                    if isLocked {
                        Image(systemName: "lock.fill")
                            .font(.system(size: horizontalSizeClass == .regular ? 18 : 24))
                            .foregroundColor(.white)
                            .shadow(radius: 4)
                    }
                }
                
                // Song Info
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Text(song.title)
                            .font(.appBodyBold)
                            .foregroundColor(isLocked ? AppColor.textTertiary : AppColor.textPrimary)
                            .lineLimit(1)
                        
                        if isLocked {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 12))
                                .foregroundColor(AppColor.textTertiary)
                        }
                    }
                    
                    Text(song.artist)
                        .font(.appCaption)
                        .foregroundColor(AppColor.textSecondary)
                        .lineLimit(1)
                    
                    HStack(spacing: 8) {
                        DifficultyBadge(difficulty: song.difficulty)
                        
                        if !isLocked && progress.completionPercentage(for: song.id.uuidString, totalSections: song.sections.count) > 0 {
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(AppColor.warning)
                                Text("\(Int(progress.completionPercentage(for: song.id.uuidString, totalSections: song.sections.count) * 100))%")
                                    .font(.appSmall)
                                    .foregroundColor(AppColor.textSecondary)
                            }
                        }
                    }
                }
                
                Spacer()
                
                if isLocked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColor.textTertiary)
                } else {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppColor.textTertiary)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppColor.cardBackground.opacity(isLocked ? 0.3 : 0.6))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    HomeView(
        viewModel: HomeViewModel(
            songRepository: SongRepository(),
            progressService: ProgressService()
        )
    )
}

