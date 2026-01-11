//
//  MainContentView.swift
//  LyricLoop
//
//  Created by Abdullah B on 15.11.2025.
//

import SwiftUI

struct MainContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @State private var showSplash: Bool = true
    @State private var showOnboarding: Bool = false
    
    private let songRepository = SongRepository()
    private let progressService = ProgressService()
    
    var body: some View {
        ZStack {
            if showSplash {
                SplashView(showOnboarding: $showOnboarding)
            } else if !hasCompletedOnboarding && showOnboarding {
                OnboardingView(showHome: $hasCompletedOnboarding)
            } else {
                TabView {
                    HomeView(
                        viewModel: HomeViewModel(
                            songRepository: songRepository,
                            progressService: progressService
                        )
                    )
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                    
                    ProfileView(progressService: progressService)
                        .tabItem {
                            Label("Profile", systemImage: "person.fill")
                        }
                }
                .tint(AppColor.accent)
            }
        }
        .onChange(of: showOnboarding) { _, newValue in
            if newValue {
                showSplash = false
            }
        }
        .onChange(of: hasCompletedOnboarding) { _, newValue in
            if newValue {
                showOnboarding = false
            }
        }
    }
}

#Preview {
    MainContentView()
}


