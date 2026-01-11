//
//  SectionCompleteView.swift
//  LyricLoop
//
//  Created by Abdullah B on 15.11.2025.
//

import SwiftUI

struct SectionCompleteView: View {
    let result: SectionResult
    let sectionTitle: String
    let onNext: () -> Void
    let onReplay: () -> Void
    let onBack: () -> Void
    
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0.0
    
    var body: some View {
        ZStack {
            AppColor.background
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                // Success Icon
                ZStack {
                    Circle()
                        .fill(AppColor.success.opacity(0.2))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(AppColor.success)
                }
                .scaleEffect(scale)
                .opacity(opacity)
                
                // Title
                Text("Great job!")
                    .font(.appTitle)
                    .foregroundColor(AppColor.textPrimary)
                    .opacity(opacity)
                
                Text(sectionTitle)
                    .font(.appSubheadline)
                    .foregroundColor(AppColor.textSecondary)
                    .opacity(opacity)
                
                // Stars
                HStack(spacing: 16) {
                    ForEach(1...3, id: \.self) { index in
                        Image(systemName: index <= result.stars ? "star.fill" : "star")
                            .font(.system(size: 40))
                            .foregroundColor(index <= result.stars ? AppColor.warning : AppColor.textTertiary)
                    }
                }
                .opacity(opacity)
                
                // Stats
                GlassCard {
                    VStack(spacing: 20) {
                        StatRow(
                            icon: "target",
                            label: "Accuracy",
                            value: "\(Int(result.accuracy * 100))%"
                        )
                        
                        Divider()
                            .background(AppColor.textTertiary.opacity(0.3))
                        
                        StatRow(
                            icon: "xmark.circle",
                            label: "Mistakes",
                            value: "\(result.mistakes)"
                        )
                        
                        Divider()
                            .background(AppColor.textTertiary.opacity(0.3))
                        
                        StatRow(
                            icon: "clock",
                            label: "Time",
                            value: formatTime(result.timeTaken)
                        )
                    }
                }
                .padding(.horizontal, 20)
                .opacity(opacity)
                
                Spacer()
                
                // Buttons
                VStack(spacing: 16) {
                    GradientButton(title: "Next Section", icon: "arrow.right") {
                        onNext()
                    }
                    .padding(.horizontal, 20)
                    
                    HStack(spacing: 16) {
                        Button(action: onReplay) {
                            HStack {
                                Image(systemName: "arrow.counterclockwise")
                                Text("Replay Section")
                            }
                            .font(.appBody)
                            .foregroundColor(AppColor.textPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(AppColor.cardBackground)
                            .cornerRadius(16)
                        }
                        
                        Button(action: onBack) {
                            HStack {
                                Image(systemName: "house")
                                Text("Back to Song")
                            }
                            .font(.appBody)
                            .foregroundColor(AppColor.textPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(AppColor.cardBackground)
                            .cornerRadius(16)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 40)
                .opacity(opacity)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return "\(minutes):\(String(format: "%02d", seconds))"
    }
}

struct StatRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(AppColor.primaryGradient)
                .frame(width: 30)
            
            Text(label)
                .font(.appBody)
                .foregroundColor(AppColor.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(.appBodyBold)
                .foregroundColor(AppColor.textPrimary)
        }
    }
}

#Preview {
    SectionCompleteView(
        result: SectionResult(stars: 3, accuracy: 0.95, mistakes: 0, timeTaken: 45),
        sectionTitle: "Chorus",
        onNext: {},
        onReplay: {},
        onBack: {}
    )
}


