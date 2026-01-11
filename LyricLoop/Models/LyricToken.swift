//
//  LyricToken.swift
//  LyricLoop
//
//  Created by Abdullah B on 15.11.2025.
//

import Foundation

struct LyricToken: Identifiable, Hashable {
    let id: UUID
    let text: String
    let isBlank: Bool
    
    init(text: String, isBlank: Bool = false) {
        self.id = UUID()
        self.text = text
        self.isBlank = isBlank
    }
}

