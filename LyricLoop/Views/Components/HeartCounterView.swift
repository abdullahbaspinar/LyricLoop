//
//  HeartCounterView.swift
//  LyricLoop
//
//  Created by Abdullah B on 15.11.2025.
//

import SwiftUI

struct HeartCounterView: View {
    let hearts: Int
    let timeUntilNextHeart: TimeInterval?
    @State private var showCounter: Bool = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                showCounter.toggle()
            }
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
        .overlay(alignment: .top) {
            if showCounter && hearts < 20, let timeLeft = timeUntilNextHeart {
                VStack(spacing: 6) {
                    Text("Next Heart")
                        .font(.appCaption)
                        .foregroundColor(AppColor.textSecondary)
                    Text("\(Int(timeLeft))s")
                        .font(.appCaptionBold)
                        .foregroundColor(AppColor.accent)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(AppColor.cardBackground)
                        .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
                )
                .offset(y: -45)
                .transition(.scale.combined(with: .opacity))
            }
        }
    }
}

#Preview {
    HeartCounterView(hearts: 15, timeUntilNextHeart: 35.0)
}

