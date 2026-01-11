//
//  LyricSection.swift
//  LyricLoop
//
//  Created by Abdullah B on 15.11.2025.
//

import Foundation

struct LyricSection: Identifiable, Hashable {
    let id: UUID
    let title: String
    let fullText: String
    let tokens: [LyricToken]
    let missingTokenIndices: [Int]
    let candidateWords: [String]
    let startTime: TimeInterval // Şarkıdaki başlangıç zamanı (saniye)
    let endTime: TimeInterval // Şarkıdaki bitiş zamanı (saniye)
    
    init(id: UUID = UUID(), title: String, fullText: String, missingWords: [String], candidateWords: [String], startTime: TimeInterval = 0, endTime: TimeInterval = 0) {
        self.id = id
        self.title = title
        self.fullText = fullText
        
        // Split fullText into tokens and mark missing words as blanks
        let words = fullText.components(separatedBy: " ")
        var tokenList: [LyricToken] = []
        var missingIndices: [Int] = []
        
        for (index, word) in words.enumerated() {
            let cleanedWord = word.trimmingCharacters(in: .punctuationCharacters)
            let isMissing = missingWords.contains(cleanedWord)
            let token = LyricToken(text: word, isBlank: isMissing)
            tokenList.append(token)
            
            if isMissing {
                missingIndices.append(index)
            }
        }
        
        self.tokens = tokenList
        self.missingTokenIndices = missingIndices
        self.candidateWords = candidateWords.shuffled()
        self.startTime = startTime
        self.endTime = endTime
    }
}

