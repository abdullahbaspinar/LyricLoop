//
//  OnboardingView.swift
//  LyricLoop
//
//  Created by Abdullah B on 15.11.2025.
//

import SwiftUI

struct OnboardingView: View {
    @State private var currentPage: Int = 0
    @Binding var showHome: Bool
    
    let features = [
        OnboardingFeature(
            icon: "music.note.list",
            title: "Listen & Fill the Blanks",
            description: "Listen to music and complete lyrics by filling in the missing words"
        ),
        OnboardingFeature(
            icon: "brain.head.profile",
            title: "Improve Vocabulary & Listening",
            description: "Enhance your English skills through engaging music-based exercises"
        ),
        OnboardingFeature(
            icon: "star.fill",
            title: "Collect Stars and Unlock Songs",
            description: "Earn stars by completing sections and unlock new challenges"
        )
    ]
    
    var body: some View {
        ZStack {
            AppColor.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    Text("Learn English")
                        .font(.appTitle)
                        .foregroundColor(AppColor.textPrimary)
                    
                    Text("Through Music")
                        .font(.appHeadline)
                        .foregroundColor(AppColor.textSecondary)
                }
                .padding(.top, 60)
                .padding(.bottom, 40)
                
                // Feature Cards
                TabView(selection: $currentPage) {
                    ForEach(Array(features.enumerated()), id: \.offset) { index, feature in
                        OnboardingCard(feature: feature)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                .frame(height: 400)
                
                Spacer()
                
                // Buttons
                VStack(spacing: 16) {
                    GradientButton(title: "Get Started", icon: "arrow.right") {
                        showHome = true
                    }
                    .padding(.horizontal, 24)
                    
                    Button(action: {
                        showHome = true
                    }) {
                        Text("Continue as Guest")
                            .font(.appBody)
                            .foregroundColor(AppColor.textSecondary)
                    }
                }
                .padding(.bottom, 40)
            }
        }
    }
}

struct OnboardingFeature {
    let icon: String
    let title: String
    let description: String
}

struct OnboardingCard: View {
    let feature: OnboardingFeature
    
    var body: some View {
        GlassCard {
            VStack(spacing: 24) {
                Image(systemName: feature.icon)
                    .font(.system(size: 60, weight: .light))
                    .foregroundStyle(AppColor.primaryGradient)
                
                Text(feature.title)
                    .font(.appHeadline)
                    .foregroundColor(AppColor.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text(feature.description)
                    .font(.appBody)
                    .foregroundColor(AppColor.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(32)
        }
        .padding(.horizontal, 24)
    }
}

#Preview {
    OnboardingView(showHome: .constant(false))
}


