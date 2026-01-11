# 🎵 LyricLoop

**LyricLoop** is an educational music-based English learning game built with SwiftUI. Learn English through interactive lyric completion challenges while listening to your favorite songs.

## ✨ Features

### 🎮 Core Gameplay
- **Fill-in-the-Blanks**: Complete song lyrics by selecting the correct words
- **Real-time Audio Playback**: Listen to songs while playing, with precise timing control
- **Section-based Learning**: Break down songs into manageable sections
- **Difficulty Levels**: Beginner, Intermediate, and Advanced challenges

### 🏆 Achievement System
- **10 Unique Achievements**: Unlock rewards as you progress
  - First Steps - Complete your first section
  - Star Collector - Earn 100 stars
  - Star Master - Earn 500 stars
  - On Fire - Maintain a 7-day streak
  - Master Learner - Reach level 10
  - Perfect Section - Complete a section with 3 stars
  - Speed Demon - Complete 5 sections in one session
  - Heart Breaker - Use all 20 hearts
  - Completionist - Complete all sections of a song
  - Level Up - Reach level 5

### ❤️ Heart System
- **20 Hearts Maximum**: Start with 20 hearts
- **Auto-refill**: 1 heart every minute
- **Smart Tracking**: Hearts persist across sessions
- **Visual Feedback**: See remaining time until next heart

### 📊 Progress Tracking
- **XP System**: Earn experience points for completing sections
- **Level Progression**: Level up as you gain XP
- **Streak Tracking**: Maintain daily streaks
- **Section Completion**: Track your progress through each song

### 🎨 Modern UI/UX
- **Dark Gradient Theme**: Beautiful glassmorphism design
- **Smooth Animations**: Polished transitions and feedback
- **SF Symbols**: Native iOS iconography
- **Responsive Layout**: Optimized for all iPhone sizes

## 🏗️ Architecture

LyricLoop follows **MVVM (Model-View-ViewModel)** architecture with dependency injection:

```
LyricLoop/
├── Models/
│   ├── Song.swift
│   ├── LyricSection.swift
│   ├── LyricToken.swift
│   ├── Difficulty.swift
│   ├── UserProgress.swift
│   └── Achievement.swift
├── ViewModels/
│   ├── GameViewModel.swift
│   ├── HomeViewModel.swift
│   └── SongDetailViewModel.swift
├── Views/
│   ├── HomeView.swift
│   ├── GameView.swift
│   ├── SongDetailView.swift
│   ├── ProfileView.swift
│   └── Components/
│       ├── HeartCounterView.swift
│       ├── GradientButton.swift
│       ├── GlassCard.swift
│       └── DifficultyBadge.swift
├── Services/
│   ├── AudioService.swift
│   ├── ProgressService.swift
│   ├── SongRepository.swift
│   └── SoundEffectService.swift
└── Theme/
    ├── AppColor.swift
    └── AppTypography.swift
```

## 🚀 Getting Started

### Prerequisites
- Xcode 15.0 or later
- iOS 17.0+ deployment target
- Swift 5.9+

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/LyricLoop.git
   cd LyricLoop
   ```

2. **Open in Xcode**
   ```bash
   open LyricLoop.xcodeproj
   ```

3. **Add Music Files** (Optional)
   - Add your MP3/M4A files to the project
   - Update `SongRepository.swift` with your song data
   - Set the `audioFileName` property for each song

4. **Build and Run**
   - Select your target device or simulator
   - Press `Cmd + R` to build and run

## 📱 Usage

### Playing a Song
1. Browse available songs on the home screen
2. Select a song to view details
3. Choose a section or start from the beginning
4. Listen to the audio and fill in the missing words
5. Earn stars based on accuracy and speed

### Managing Hearts
- Hearts are used when you make a mistake
- Tap the heart icon to see remaining time until next heart
- Hearts automatically refill every minute

### Tracking Progress
- View your profile to see:
  - Current level and XP
  - Daily streak
  - Unlocked achievements
  - Completed sections

## 🛠️ Technical Details

### Key Technologies
- **SwiftUI**: Modern declarative UI framework
- **Combine**: Reactive programming for state management
- **AVFoundation**: Audio playback and control
- **UserDefaults**: Persistent storage for user progress
- **NavigationStack**: iOS 17+ navigation system

### Design Patterns
- **MVVM**: Separation of concerns
- **Dependency Injection**: Loose coupling between components
- **Protocol-Oriented Programming**: Flexible service abstractions
- **Observer Pattern**: Combine publishers for reactive updates

### Audio Playback
- Precise timing control with `AVAudioPlayer`
- Section-based playback with start/end times
- Automatic pause/resume functionality
- Progress tracking and visualization

## 📝 Adding New Songs

To add a new song:

1. **Add audio file** to the project
2. **Update `SongRepository.swift`**:
   ```swift
   Song(
       id: UUID(),
       title: "Your Song Title",
       artist: "Artist Name",
       difficulty: .intermediate,
       coverImageName: "music.note",
       duration: 180, // in seconds
       audioFileName: "YourSong.mp3",
       sections: [
           LyricSection(
               title: "Verse 1",
               fullText: "Your lyrics here",
               missingWords: ["word1", "word2"],
               candidateWords: ["word1", "word2", "distractor1", "distractor2"],
               startTime: 10.0, // when lyrics start
               endTime: 30.0    // when lyrics end
           )
       ]
   )
   ```

## 🎯 Future Enhancements

- [ ] Multiplayer mode
- [ ] Social features and leaderboards
- [ ] More songs and genres
- [ ] Custom difficulty settings
- [ ] Offline mode
- [ ] Dark/Light theme toggle
- [ ] Localization support

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👤 Author

**Abdullah B**

- GitHub: [@yourusername](https://github.com/yourusername)

## 🙏 Acknowledgments

- Built with SwiftUI and modern iOS development practices
- Inspired by language learning through music
- Uses SF Symbols for native iOS iconography

---

<div align="center">
  Made with ❤️ using SwiftUI
</div>


# LyricLoop
