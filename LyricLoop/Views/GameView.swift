//
//  GameView.swift
//  LyricLoop
//
//  Created by Abdullah B on 15.11.2025.
//

import SwiftUI
import Combine

struct GameView: View {
    @StateObject private var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showSectionComplete: Bool = false
    let startSectionIndex: Int
    
    init(viewModel: GameViewModel, startSectionIndex: Int = 0) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.startSectionIndex = startSectionIndex
    }
    
    var body: some View {
        ZStack {
            AppColor.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Bar
                HStack {
                    Button(action: {
                        viewModel.backToSong()
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(AppColor.textPrimary)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 4) {
                        Text(viewModel.song.title)
                            .font(.appBodyBold)
                            .foregroundColor(AppColor.textPrimary)
                            .lineLimit(1)
                        
                        DifficultyBadge(difficulty: viewModel.song.difficulty)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        // Hearts (clickable - pauses audio)
                        Button(action: {
                            viewModel.toggleHeartPopup()
                        }) {
                            HeartCounterView(
                                hearts: viewModel.hearts,
                                timeUntilNextHeart: viewModel.timeUntilNextHeart
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Score
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 16))
                                .foregroundColor(AppColor.warning)
                            Text("\(viewModel.score)")
                                .font(.appBodyBold)
                                .foregroundColor(AppColor.textPrimary)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(AppColor.cardBackground.opacity(0.5))
                
                // Progress Bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(AppColor.cardBackground)
                            .frame(height: 4)
                        
                        Rectangle()
                            .fill(AppColor.primaryGradient)
                            .frame(width: geometry.size.width * viewModel.audioService.progress.value, height: 4)
                    }
                }
                .frame(height: 4)
                .onReceive(viewModel.audioService.progress) { progress in
                    // Progress updates automatically
                }
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Lyric Display
                        if let section = viewModel.currentSection {
                            VStack(spacing: 24) {
                                Text(section.title)
                                    .font(.appSubheadline)
                                    .foregroundColor(AppColor.textSecondary)
                                    .padding(.top, 32)
                                
                                // Lyric Text with Blanks
                                VStack(spacing: 12) {
                                    FlexibleLyricText(viewModel: viewModel)
                                }
                                .padding(.horizontal, 20)
                                
                                // Section Progress
                                VStack(spacing: 8) {
                                    HStack {
                                        Text("Section Progress")
                                            .font(.appCaption)
                                            .foregroundColor(AppColor.textSecondary)
                                        Spacer()
                                        Text("\(Int(viewModel.progress * 100))%")
                                            .font(.appCaptionBold)
                                            .foregroundColor(AppColor.accent)
                                    }
                                    
                                    GeometryReader { geometry in
                                        ZStack(alignment: .leading) {
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(AppColor.cardBackground)
                                                .frame(height: 8)
                                            
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(AppColor.primaryGradient)
                                                .frame(width: geometry.size.width * viewModel.progress, height: 8)
                                        }
                                    }
                                    .frame(height: 8)
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(AppColor.cardBackground.opacity(0.6))
                                )
                                .padding(.horizontal, 20)
                            }
                        }
                        
                        // Word Bank
                        if let section = viewModel.currentSection {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Word Bank")
                                    .font(.appHeadline)
                                    .foregroundColor(AppColor.textPrimary)
                                    .padding(.horizontal, 20)
                                
                                if viewModel.hearts > 0 {
                                    FlowLayout(spacing: 12) {
                                        ForEach(viewModel.availableCandidates, id: \.self) { word in
                                            WordChip(word: word) {
                                                viewModel.selectCandidate(word)
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                } else {
                                    // No hearts message
                                    VStack(spacing: 12) {
                                        Image(systemName: "heart.slash.fill")
                                            .font(.system(size: 40))
                                            .foregroundColor(AppColor.textTertiary)
                                        
                                        Text("No Hearts!")
                                            .font(.appHeadline)
                                            .foregroundColor(AppColor.textPrimary)
                                        
                                        if let timeLeft = viewModel.timeUntilNextHeart {
                                            Text("Next heart: \(Int(timeLeft)) seconds")
                                                .font(.appBody)
                                                .foregroundColor(AppColor.textSecondary)
                                        } else {
                                            Text("New heart will arrive in 1 minute")
                                                .font(.appBody)
                                                .foregroundColor(AppColor.textSecondary)
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 40)
                                    .padding(.horizontal, 20)
                                }
                            }
                        }
                        
                        // Replay Button (always visible)
                        VStack(spacing: 12) {
                            if viewModel.audioFinished && !viewModel.isSectionComplete {
                                Text("Song ended")
                                    .font(.appCaption)
                                    .foregroundColor(AppColor.textSecondary)
                            }
                            
                            Button(action: {
                                viewModel.replayAudio()
                            }) {
                                HStack {
                                    Image(systemName: "arrow.counterclockwise")
                                    Text("Replay")
                                }
                                .font(.appBodyBold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(AppColor.primaryGradient)
                                .cornerRadius(12)
                            }
                            .padding(.horizontal, 20)
                        }
                        .padding(.top, 20)
                        
                        Spacer(minLength: 40)
                    }
                }
            }
            
            // Feedback Overlay
            if let feedback = viewModel.feedback {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        FeedbackView(feedback: feedback)
                        Spacer()
                    }
                    Spacer()
                }
                .background(Color.black.opacity(0.3))
                .allowsHitTesting(false)
            }
            
            // Heart Popup
            if viewModel.showHeartPopup {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .onTapGesture {
                        viewModel.toggleHeartPopup()
                    }
                
                VStack(spacing: 20) {
                    Text("Hearts")
                        .font(.appHeadline)
                        .foregroundColor(AppColor.textPrimary)
                    
                    HStack(spacing: 8) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 24))
                            .foregroundColor(AppColor.error)
                        Text("\(viewModel.hearts)/20")
                            .font(.appTitle)
                            .foregroundColor(AppColor.textPrimary)
                    }
                    
                    if let timeLeft = viewModel.timeUntilNextHeart, viewModel.hearts < 20 {
                        VStack(spacing: 8) {
                            Text("Next Heart")
                                .font(.appCaption)
                                .foregroundColor(AppColor.textSecondary)
                            Text("\(Int(timeLeft))s")
                                .font(.appHeadline)
                                .foregroundColor(AppColor.accent)
                        }
                    } else if viewModel.hearts >= 20 {
                        Text("Full Hearts!")
                            .font(.appBody)
                            .foregroundColor(AppColor.textSecondary)
                    }
                    
                    Button(action: {
                        viewModel.toggleHeartPopup()
                    }) {
                        Text("Close")
                            .font(.appBodyBold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(AppColor.primaryGradient)
                            .cornerRadius(12)
                    }
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(AppColor.cardBackground)
                        .shadow(radius: 20)
                )
                .padding(.horizontal, 40)
            }
        }
        .onAppear {
            if startSectionIndex > 0 {
                viewModel.currentSectionIndex = startSectionIndex
                viewModel.setupCurrentSection(shouldPlay: false)
            }
            // Şarkıyı başlat
            viewModel.startPlaying()
        }
        .onChange(of: viewModel.isSectionComplete) { _, isComplete in
            if isComplete {
                showSectionComplete = true
            }
        }
        .fullScreenCover(isPresented: $showSectionComplete) {
            if let result = viewModel.sectionResult {
                SectionCompleteView(
                    result: result,
                    sectionTitle: viewModel.currentSection?.title ?? "",
                    onNext: {
                        viewModel.goToNextSection()
                        showSectionComplete = false
                        // setupCurrentSection zaten şarkıyı başlatıyor
                    },
                    onReplay: {
                        showSectionComplete = false
                        viewModel.restartSection()
                    },
                    onBack: {
                        viewModel.backToSong()
                        dismiss()
                    }
                )
            }
        }
    }
}

struct FlexibleLyricText: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        FlowLayout(spacing: 8) {
            ForEach(Array(viewModel.formattedLyricText.enumerated()), id: \.offset) { index, item in
                if item.isBlank {
                    if item.isFilled {
                        Text(item.filledText ?? "")
                            .font(.appHeadline)
                            .foregroundColor(AppColor.success)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(AppColor.success.opacity(0.2))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(AppColor.success, lineWidth: 2)
                            )
                    } else {
                        Text("____")
                            .font(.appHeadline)
                            .foregroundColor(AppColor.accent)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(AppColor.accent.opacity(0.1))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(AppColor.accent.opacity(0.5), lineWidth: 2)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(AppColor.accent.opacity(0.3), lineWidth: 1)
                                    .blur(radius: 4)
                            )
                    }
                } else {
                    Text(item.text)
                        .font(.appHeadline)
                        .foregroundColor(AppColor.textPrimary)
                        .padding(.vertical, 4)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct WordChip: View {
    let word: String
    let action: () -> Void
    @State private var isPressed: Bool = false
    
    var body: some View {
        Button(action: {
            SoundEffectService.shared.playButtonTap()
            action()
        }) {
            Text(word)
                .font(.appBodyBold)
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .fill(AppColor.primaryGradient)
                )
                .shadow(color: AppColor.primaryPurple.opacity(0.3), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        let result = FlowResult(
            in: maxWidth,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.frames[index].minX,
                                     y: bounds.minY + result.frames[index].minY),
                         proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var frames: [CGRect] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                frames.append(CGRect(x: currentX, y: currentY, width: size.width, height: size.height))
                lineHeight = max(lineHeight, size.height)
                currentX += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

struct FeedbackView: View {
    let feedback: GameFeedback
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0.0
    
    var body: some View {
        Text(feedback.message)
            .font(.appHeadline)
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(feedback.isCorrect ? AppColor.success : AppColor.error)
            )
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    scale = 1.0
                    opacity = 1.0
                }
            }
    }
}

#Preview {
    GameView(
        viewModel: GameViewModel(
            song: SongRepository.createDemoSongs()[0],
            audioService: MockAudioService(duration: 180),
            progressService: ProgressService()
        )
    )
}

