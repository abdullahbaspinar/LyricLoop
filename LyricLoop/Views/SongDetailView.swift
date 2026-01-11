//
//  SongDetailView.swift
//  LyricLoop
//
//  Created by Abdullah B on 15.11.2025.
//

import SwiftUI
import UIKit

struct SongDetailView: View {
    @StateObject private var viewModel: SongDetailViewModel
    @State private var showGame: Bool = false
    @State private var selectedSectionIndex: Int = 0
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    init(viewModel: SongDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    private var coverHeight: CGFloat {
        horizontalSizeClass == .regular ? 200 : 300 // Tablet için daha küçük
    }
    
    var body: some View {
        ZStack {
            AppColor.background
                .ignoresSafeArea()
            
            if let song = viewModel.song {
                ScrollView {
                    VStack(spacing: 24) {
                        // Cover Art
                        ZStack {
                            RoundedRectangle(cornerRadius: 24)
                                .fill(AppColor.cardGradient)
                                .frame(height: coverHeight)
                            
                            Group {
                                if UIImage(named: song.coverImageName) != nil {
                                    Image(song.coverImageName)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                } else {
                                    Image(systemName: song.coverImageName)
                                        .font(.system(size: horizontalSizeClass == .regular ? 60 : 80))
                                        .foregroundStyle(AppColor.primaryGradient)
                                }
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        // Song Info
                        VStack(spacing: 12) {
                            Text(song.title)
                                .font(.appTitle)
                                .foregroundColor(AppColor.textPrimary)
                                .multilineTextAlignment(.center)
                            
                            Text(song.artist)
                                .font(.appSubheadline)
                                .foregroundColor(AppColor.textSecondary)
                            
                            HStack(spacing: 16) {
                                DifficultyBadge(difficulty: song.difficulty)
                                
                                HStack(spacing: 4) {
                                    Image(systemName: "clock")
                                        .font(.system(size: 12))
                                        .foregroundColor(AppColor.textSecondary)
                                    Text(song.formattedDuration)
                                        .font(.appCaption)
                                        .foregroundColor(AppColor.textSecondary)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Progress Indicator
                        if viewModel.completionPercentage > 0 {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Progress")
                                        .font(.appBodyBold)
                                        .foregroundColor(AppColor.textPrimary)
                                    Spacer()
                                    Text("\(Int(viewModel.completionPercentage * 100))%")
                                        .font(.appBodyBold)
                                        .foregroundColor(AppColor.accent)
                                }
                                
                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(AppColor.cardBackground)
                                            .frame(height: 8)
                                        
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(AppColor.primaryGradient)
                                            .frame(width: geometry.size.width * viewModel.completionPercentage, height: 8)
                                    }
                                }
                                .frame(height: 8)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(AppColor.cardBackground.opacity(0.6))
                            )
                            .padding(.horizontal, 20)
                        }
                        
                        // Sections List
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Sections")
                                    .font(.appHeadline)
                                    .foregroundColor(AppColor.textPrimary)
                                
                                Spacer()
                                
                                // Completion Info
                                if viewModel.completedSectionsCount > 0 {
                                    HStack(spacing: 6) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 14))
                                            .foregroundColor(AppColor.success)
                                        Text("\(viewModel.completedSectionsCount)/\(viewModel.totalSectionsCount) completed")
                                            .font(.appCaption)
                                            .foregroundColor(AppColor.textSecondary)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            
                            // Completion Info Card
                            if viewModel.completedSectionsCount > 0 {
                                HStack(spacing: 12) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(AppColor.success)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("\(viewModel.completedSectionsCount) of \(viewModel.totalSectionsCount) sections completed")
                                            .font(.appBodyBold)
                                            .foregroundColor(AppColor.textPrimary)
                                        
                                        Text("Keep going! Complete all sections to unlock achievements.")
                                            .font(.appCaption)
                                            .foregroundColor(AppColor.textSecondary)
                                    }
                                    
                                    Spacer()
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(AppColor.success.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(AppColor.success.opacity(0.3), lineWidth: 1)
                                        )
                                )
                                .padding(.horizontal, 20)
                            }
                            
                            ForEach(Array(song.sections.enumerated()), id: \.element.id) { index, section in
                                SectionRow(
                                    section: section,
                                    index: index + 1,
                                    isCompleted: viewModel.isSectionCompleted(section.id)
                                ) {
                                    selectedSectionIndex = index
                                    showGame = true
                                }
                            }
                        }
                        .padding(.bottom, 20)
                        
                        // Lock Message
                        if viewModel.isLocked {
                            VStack(spacing: 16) {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 48))
                                    .foregroundColor(AppColor.textTertiary)
                                
                                Text("Song Locked")
                                    .font(.appHeadline)
                                    .foregroundColor(AppColor.textPrimary)
                                
                                VStack(spacing: 8) {
                                    Text("Complete 70% of the first 3 songs to unlock")
                                        .font(.appBody)
                                        .foregroundColor(AppColor.textSecondary)
                                        .multilineTextAlignment(.center)
                                    
                                    HStack(spacing: 8) {
                                        Text("Progress:")
                                            .font(.appCaption)
                                            .foregroundColor(AppColor.textSecondary)
                                        Text("\(viewModel.xpProgressForUnlock.current) / \(viewModel.xpProgressForUnlock.required) XP")
                                            .font(.appCaptionBold)
                                            .foregroundColor(AppColor.accent)
                                    }
                                    
                                    GeometryReader { geometry in
                                        ZStack(alignment: .leading) {
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(AppColor.cardBackground)
                                                .frame(height: 8)
                                            
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(AppColor.primaryGradient)
                                                .frame(
                                                    width: geometry.size.width * min(
                                                        Double(viewModel.xpProgressForUnlock.current) / Double(viewModel.xpProgressForUnlock.required),
                                                        1.0
                                                    ),
                                                    height: 8
                                                )
                                        }
                                    }
                                    .frame(height: 8)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                            .padding(.horizontal, 20)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(AppColor.cardBackground.opacity(0.6))
                            )
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                        }
                        
                        // Play Button (sadece müzik dosyası varsa ve kilitli değilse)
                        if song.audioFileName != nil && !viewModel.isLocked {
                            GradientButton(title: "Play Song", icon: "play.fill") {
                                selectedSectionIndex = 0
                                showGame = true
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                        } else if song.audioFileName == nil {
                            VStack(spacing: 12) {
                                Text("Coming Soon")
                                    .font(.appHeadline)
                                    .foregroundColor(AppColor.textSecondary)
                                
                                Text("This song will be added very soon!")
                                    .font(.appCaption)
                                    .foregroundColor(AppColor.textTertiary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(AppColor.cardBackground.opacity(0.6))
                            )
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                        }
                    }
                }
            } else {
                ProgressView()
                    .tint(AppColor.accent)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $showGame) {
            if let song = viewModel.song {
                GameView(
                    viewModel: GameViewModel(
                        song: song,
                        audioService: RealAudioService(audioFileName: song.audioFileName, duration: song.duration),
                        progressService: viewModel.progressService
                    ),
                    startSectionIndex: selectedSectionIndex
                )
            }
        }
    }
}

struct SectionRow: View {
    let section: LyricSection
    let index: Int
    let isCompleted: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Text("Section \(index) · \(section.title)")
                            .font(.appBodyBold)
                            .foregroundColor(AppColor.textPrimary)
                        
                        if isCompleted {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(AppColor.success)
                        }
                    }
                }
                
                Spacer()
                
                if isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(AppColor.success)
                } else {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(AppColor.primaryGradient)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppColor.cardBackground.opacity(0.6))
            )
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, 20)
    }
}

#Preview {
    NavigationStack {
        SongDetailView(
            viewModel: SongDetailViewModel(
                songId: UUID(),
                songRepository: SongRepository(),
                progressService: ProgressService()
            )
        )
    }
}

