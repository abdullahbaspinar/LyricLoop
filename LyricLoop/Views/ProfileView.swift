//
//  ProfileView.swift
//  LyricLoop
//
//  Created by Abdullah B on 15.11.2025.
//

import SwiftUI
import Combine

struct ProfileView: View {
    @StateObject private var progressService: ProgressService
    @State private var userProgress: UserProgress = UserProgress()
    @State private var soundEffectsEnabled: Bool = true
    @State private var hapticsEnabled: Bool = true
    @State private var cancellables = Set<AnyCancellable>()
    
    init(progressService: ProgressService) {
        _progressService = StateObject(wrappedValue: progressService)
    }
    
    private func updateSoundEffectsSetting() {
        if let service = SoundEffectService.shared as? SoundEffectService {
            service.setSoundEffectsEnabled(soundEffectsEnabled)
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Profile Header
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(AppColor.primaryGradient)
                                    .frame(width: 100, height: 100)
                                
                                Text("AB")
                                    .font(.system(size: 40, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            
                            Text("Abdullah")
                                .font(.appHeadline)
                                .foregroundColor(AppColor.textPrimary)
                            
                            Text("Level \(userProgress.currentLevel) · \(userProgress.totalXP) XP")
                                .font(.appBody)
                                .foregroundColor(AppColor.textSecondary)
                        }
                        .padding(.top, 20)
                        
                        // Stats Cards
                        HStack(spacing: 16) {
                            StatCard(
                                icon: "flame.fill",
                                value: "\(userProgress.streak)",
                                label: "Day Streak",
                                color: AppColor.error
                            )
                            
                            StatCard(
                                icon: "star.fill",
                                value: "\(userProgress.totalXP)",
                                label: "Total XP",
                                color: AppColor.warning
                            )
                        }
                        .padding(.horizontal, 20)
                        
                        // Settings Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Settings")
                                .font(.appHeadline)
                                .foregroundColor(AppColor.textPrimary)
                                .padding(.horizontal, 20)
                            
                            GlassCard {
                                VStack(spacing: 0) {
                                    SettingRow(
                                        icon: "speaker.wave.2.fill",
                                        title: "Sound Effects",
                                        isOn: Binding(
                                            get: { soundEffectsEnabled },
                                            set: { newValue in
                                                soundEffectsEnabled = newValue
                                                updateSoundEffectsSetting()
                                            }
                                        )
                                    )
                                    
                                    Divider()
                                        .background(AppColor.textTertiary.opacity(0.3))
                                    
                                    SettingRow(
                                        icon: "hand.tap.fill",
                                        title: "Haptics",
                                        isOn: $hapticsEnabled
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // Achievements Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Achievements")
                                .font(.appHeadline)
                                .foregroundColor(AppColor.textPrimary)
                                .padding(.horizontal, 20)
                            
                            VStack(spacing: 12) {
                                ForEach(Achievement.allCases, id: \.id) { achievement in
                                    let isUnlocked = userProgress.achievements.contains(achievement.rawValue)
                                    let color: Color = {
                                        switch achievement.color {
                                        case "warning": return AppColor.warning
                                        case "error": return AppColor.error
                                        case "primaryPurple": return AppColor.primaryPurple
                                        case "accent": return AppColor.accent
                                        case "success": return AppColor.success
                                        default: return AppColor.accent
                                        }
                                    }()
                                    
                                    AchievementRow(
                                        icon: achievement.icon,
                                        title: achievement.title,
                                        description: achievement.description,
                                        isUnlocked: isUnlocked,
                                        color: color
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            // Check achievements when profile appears
            _ = progressService.checkAchievements()
            
            progressService.progress
                .receive(on: DispatchQueue.main)
                .sink { progress in
                    userProgress = progress
                }
                .store(in: &cancellables)
        }
    }
}

struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        GlassCard {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(color)
                
                Text(value)
                    .font(.appHeadline)
                    .foregroundColor(AppColor.textPrimary)
                
                Text(label)
                    .font(.appCaption)
                    .foregroundColor(AppColor.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
        }
    }
}

struct SettingRow: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(AppColor.primaryGradient)
                .frame(width: 30)
            
            Text(title)
                .font(.appBody)
                .foregroundColor(AppColor.textPrimary)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .tint(AppColor.accent)
        }
        .padding(.vertical, 12)
    }
}

struct AchievementRow: View {
    let icon: String
    let title: String
    let description: String
    let isUnlocked: Bool
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? color.opacity(0.2) : AppColor.cardBackground)
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(isUnlocked ? color : AppColor.textTertiary)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.appBodyBold)
                    .foregroundColor(isUnlocked ? AppColor.textPrimary : AppColor.textTertiary)
                
                Text(description)
                    .font(.appCaption)
                    .foregroundColor(isUnlocked ? AppColor.textSecondary : AppColor.textTertiary)
            }
            
            Spacer()
            
            if isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(AppColor.success)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColor.cardBackground.opacity(0.6))
        )
    }
}

#Preview {
    ProfileView(progressService: ProgressService())
}

