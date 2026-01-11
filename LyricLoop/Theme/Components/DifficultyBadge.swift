//
//  DifficultyBadge.swift
//  LyricLoop
//
//  Created by Abdullah B on 15.11.2025.
//

import SwiftUI

struct DifficultyBadge: View {
    let difficulty: Difficulty
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: difficulty.icon)
                .font(.system(size: 10))
            Text(difficulty.rawValue)
                .font(.appSmall)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(colorForDifficulty)
        )
    }
    
    private var colorForDifficulty: Color {
        switch difficulty {
        case .beginner:
            return AppColor.success
        case .intermediate:
            return AppColor.warning
        case .advanced:
            return AppColor.error
        }
    }
}


