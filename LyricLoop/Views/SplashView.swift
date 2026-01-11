//
//  SplashView.swift
//  LyricLoop
//
//  Created by Abdullah B on 15.11.2025.
//

import SwiftUI

struct SplashView: View {
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0.0
    @Binding var showOnboarding: Bool
    
    var body: some View {
        ZStack {
            AppColor.primaryGradient
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 120, height: 120)
                        .blur(radius: 20)
                    
                    HStack(spacing: 8) {
                        Image(systemName: "headphones")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.white)
                        Image(systemName: "music.note")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .scaleEffect(scale)
                .opacity(opacity)
                
                Text("LyricLoop")
                    .font(.appTitle)
                    .foregroundColor(.white)
                    .opacity(opacity)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                scale = 1.0
                opacity = 1.0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                withAnimation(.easeIn(duration: 0.3)) {
                    showOnboarding = true
                }
            }
        }
    }
}

#Preview {
    SplashView(showOnboarding: .constant(false))
}


