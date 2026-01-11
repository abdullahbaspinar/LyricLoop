//
//  AppColor.swift
//  LyricLoop
//
//  Created by Abdullah B on 15.11.2025.
//

import SwiftUI

struct AppColor {
    // Primary gradient colors
    static let primaryPurple = Color(red: 0.6, green: 0.3, blue: 0.9)
    static let primaryPink = Color(red: 0.9, green: 0.3, blue: 0.6)
    static let primaryBlue = Color(red: 0.3, green: 0.5, blue: 0.9)
    
    // Background colors
    static let background = Color(red: 0.1, green: 0.1, blue: 0.15)
    static let cardBackground = Color(red: 0.15, green: 0.15, blue: 0.2)
    static let cardBackgroundLight = Color(red: 0.2, green: 0.2, blue: 0.25)
    
    // Text colors
    static let textPrimary = Color.white
    static let textSecondary = Color(red: 0.7, green: 0.7, blue: 0.75)
    static let textTertiary = Color(red: 0.5, green: 0.5, blue: 0.55)
    
    // Accent colors
    static let accent = primaryPurple
    static let success = Color(red: 0.2, green: 0.8, blue: 0.4)
    static let error = Color(red: 0.9, green: 0.3, blue: 0.3)
    static let warning = Color(red: 1.0, green: 0.7, blue: 0.2)
    
    // Gradient
    static var primaryGradient: LinearGradient {
        LinearGradient(
            colors: [primaryPurple, primaryPink, primaryBlue],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static var cardGradient: LinearGradient {
        LinearGradient(
            colors: [cardBackground, cardBackgroundLight],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}


