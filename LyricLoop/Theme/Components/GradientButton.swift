//
//  GradientButton.swift
//  LyricLoop
//
//  Created by Abdullah B on 15.11.2025.
//

import SwiftUI

struct GradientButton: View {
    let title: String
    let action: () -> Void
    var icon: String? = nil
    
    var body: some View {
        Button(action: {
            SoundEffectService.shared.playButtonTap()
            action()
        }) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.appBodyBold)
                }
                Text(title)
                    .font(.appBodyBold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(AppColor.primaryGradient)
            .cornerRadius(16)
            .shadow(color: AppColor.primaryPurple.opacity(0.4), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

