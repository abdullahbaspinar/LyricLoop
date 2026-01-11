//
//  SongRepository.swift
//  LyricLoop
//
//  Created by Abdullah B on 15.11.2025.
//

import Foundation

protocol SongRepositoryProtocol {
    func getAllSongs() -> [Song]
    func getSong(by id: UUID) -> Song?
    func getSongs(by difficulty: Difficulty?) -> [Song]
}

class SongRepository: SongRepositoryProtocol {
    private let songs: [Song]
    
    init() {
        self.songs = SongRepository.createDemoSongs()
    }
    
    func getAllSongs() -> [Song] {
        return songs
    }
    
    func getSong(by id: UUID) -> Song? {
        return songs.first { $0.id == id }
    }
    
    func getSongs(by difficulty: Difficulty?) -> [Song] {
        guard let difficulty = difficulty else {
            return songs
        }
        return songs.filter { $0.difficulty == difficulty }
    }
    
    // Sabit şarkı ID'leri (kilit mekanizması için)
    static let skyfallId = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
    static let backToBlackId = UUID(uuidString: "00000000-0000-0000-0000-000000000002")!
    static let demonsId = UUID(uuidString: "00000000-0000-0000-0000-000000000003")!
    static let tooGoodAtGoodbyesId = UUID(uuidString: "00000000-0000-0000-0000-000000000004")!
    static let arabellaId = UUID(uuidString: "00000000-0000-0000-0000-000000000005")!
    
    // Önceki 3 şarkı ID'leri (Skyfall, Back to Black, Demons)
    static let initialSongsIds: [UUID] = [skyfallId, backToBlackId, demonsId]
    
    static func createDemoSongs() -> [Song] {
        return [
            Song(
                id: skyfallId,
                title: "Skyfall",
                artist: "Adele",
                difficulty: .intermediate,
                coverImageName: "adele-skyfall",
                duration: 285,
                audioFileName: "Adele - Skyfall.mp3",
                sections: [
                    LyricSection(
                        title: "Verse 1",
                        fullText: "This is the end hold your breath and count to ten feel the earth move and then hear my heart burst again for this is the end I've drowned and dreamt this moment",
                        missingWords: ["end", "heart", "moment"],
                        candidateWords: ["end", "heart", "moment", "start", "soul", "time", "dream"],
                        startTime: 33.55, // [00:33.55] This is the end
                        endTime: 67.05 // [01:03.55] + 1.5 + 2 saniye = sözler bittikten sonra 2 saniye daha
                    ),
                    LyricSection(
                        title: "Chorus 1",
                        fullText: "Let the sky fall when it crumbles we will stand tall face it all together at skyfall",
                        missingWords: ["sky", "together"],
                        candidateWords: ["sky", "together", "world", "forever", "rain", "always"],
                        startTime: 84.45, // [01:24.45] Let the sky fall
                        endTime: 110.25 // [01:48.75] + 1.5 saniye = sözler bittikten sonra
                    ),
                    LyricSection(
                        title: "Verse 2",
                        fullText: "Skyfall is where we start a thousand miles and poles apart where worlds collide and days are dark you may have my number you can take my name but you'll never have my heart",
                        missingWords: ["start", "dark", "heart"],
                        candidateWords: ["start", "dark", "heart", "begin", "night", "soul", "love"],
                        startTime: 121.95, // [02:01.95] Skyfall is where we start
                        endTime: 149.75 // [02:28.25] + 1.5 saniye = sözler bittikten sonra
                    ),
                    LyricSection(
                        title: "Chorus 2",
                        fullText: "Where you go I go what you see I see I know I'd never be me without the security of your loving arms keeping me from harm put your hand in my hand and we'll stand",
                        missingWords: ["see", "arms", "stand"],
                        candidateWords: ["see", "arms", "stand", "know", "heart", "tall", "feel", "love", "strong"],
                        startTime: 199.05, // [03:19.05] Where you go I go
                        endTime: 226.15 // [03:44.65] + 1.5 saniye = sözler bittikten sonra
                    ),
                    LyricSection(
                        title: "Final Chorus",
                        fullText: "Let the sky fall when it crumbles we will stand tall face it all together at skyfall let the sky fall we will stand tall at skyfall",
                        missingWords: ["sky", "tall", "skyfall"],
                        candidateWords: ["sky", "tall", "skyfall", "world", "strong", "rain", "proud", "together"],
                        startTime: 251.25, // [04:11.25] Let the sky fall
                        endTime: 262.75 // [04:21.25] + 1.5 saniye = sözler bittikten sonra
                    )
                ]
            ),
            Song(
                id: backToBlackId,
                title: "Back to Black",
                artist: "Amy Winehouse",
                difficulty: .beginner,
                coverImageName: "back-to-black",
                duration: 241, // ~4 minutes
                audioFileName: "Amy Winehouse - Back To Black.mp3",
                sections: [
                    LyricSection(
                        title: "Verse 1",
                        fullText: "He left no time to regret kept his **** wet with his same old safe bet me and my head high and my tears dry get on without my guy",
                        missingWords: ["regret", "high", "guy"],
                        candidateWords: ["regret", "high", "guy", "time", "low", "girl", "bet", "dry", "boy"],
                        startTime: 16.30, // [00:16.30] He left no time to regret
                        endTime: 46.90 // [00:46.90] You went back to what you know
                    ),
                    LyricSection(
                        title: "Verse 2",
                        fullText: "You went back to what you know so far removed from all that we went through and I tread a troubled track my odds are stacked I'll go back to black",
                        missingWords: ["know", "track", "black"],
                        candidateWords: ["know", "track", "black", "see", "path", "white", "feel", "road", "blue"],
                        startTime: 46.90, // [00:46.90] You went back to what you know
                        endTime: 108.50 // [01:08.50] I'll go back to black
                    ),
                    LyricSection(
                        title: "Chorus 1",
                        fullText: "We only said goodbye with words I died a hundred times you go back to her and I go back to I go back to us",
                        missingWords: ["words", "her", "us"],
                        candidateWords: ["words", "her", "us", "deeds", "him", "you", "actions", "them", "me"],
                        startTime: 78.20, // [01:18.20] = 60 + 18.20 = 78.20
                        endTime: 101.70 // [01:34.20] = 60 + 34.20 = 94.20 + 1.5
                    ),
                    LyricSection(
                        title: "Verse 3",
                        fullText: "I love you much it's not enough you love blow and I love puff and life is like a pipe and I'm a tiny penny rollin' up the walls inside",
                        missingWords: ["enough", "puff", "pipe"],
                        candidateWords: ["enough", "puff", "pipe", "much", "smoke", "tube", "more", "air", "line"],
                        startTime: 99.70, // [01:39.70] = 60 + 39.70 = 99.70
                        endTime: 126.30 // [01:58.80] = 60 + 58.80 = 118.80 + 1.5
                    ),
                    LyricSection(
                        title: "Final Chorus",
                        fullText: "We only said goodbye with words I died a hundred times you go back to her and I go back to we only said goodbye with words I died a hundred times you go back to her and I go back to black black black black",
                        missingWords: ["words", "her", "black"],
                        candidateWords: ["words", "her", "black", "deeds", "him", "white", "actions", "them", "blue"],
                        startTime: 129.00, // [02:09.00] = 120 + 9 = 129
                        endTime: 183.00 // [03:01.50] = 180 + 1.50 = 181.50 + 1.5
                    )
                ]
            ),
            Song(
                id: demonsId,
                title: "Demons",
                artist: "Imagine Dragons",
                difficulty: .intermediate,
                coverImageName: "Imagine_Dragons",
                duration: 177, // ~3 minutes
                audioFileName: "Imagine Dragons - Demons (Official Music Video).mp3",
                sections: [
                    LyricSection(
                        title: "Verse 1",
                        fullText: "When the days are cold and the cards all fold and the saints we see are all made of gold when your dreams all fail and the ones we hail are the worst of all and the blood's run stale",
                        missingWords: ["cold", "gold", "stale"],
                        candidateWords: ["cold", "gold", "stale", "warm", "silver", "fresh", "hot", "bronze", "old"],
                        startTime: 12.30, // [00:12.30] When the days are cold
                        endTime: 36.30 // [00:34.80] - 1.5 + 3 = I wanna hide the truth (bitiş 1.5 saniye sonra)
                    ),
                    LyricSection(
                        title: "Chorus 1",
                        fullText: "I wanna hide the truth I wanna shelter you but with the beast inside there's nowhere we can hide no matter what we breed we still are made of greed this is my kingdom come this is my kingdom come when you feel my heat look into my eyes it's where my demons hide it's where my demons hide don't get too close it's dark inside it's where my demons hide it's where my demons hide",
                        missingWords: ["truth", "hide", "demons"],
                        candidateWords: ["truth", "hide", "demons", "lies", "show", "angels", "facts", "seek", "ghosts"],
                        startTime: 34.80, // [00:34.80] = 34.80
                        endTime: 80.20 // [01:14.70] = 60 + 14.70 = 74.70 + 1.5
                    ),
                    LyricSection(
                        title: "Verse 2",
                        fullText: "At the curtains call it's the last of all when the lights fade out all the sinners crawl so they dug your grave and the masquerade will come calling out at the mess you've made don't wanna let you down but I am hell bound though this is all for you don't wanna hide the truth no matter what we breed we still are made of greed this is my kingdom come this is my kingdom come",
                        missingWords: ["call", "grave", "truth"],
                        candidateWords: ["call", "grave", "truth", "fall", "tomb", "lies", "end", "death", "facts"],
                        startTime: 77.80, // [01:17.80] = 60 + 17.80 = 77.80
                        endTime: 121.80 // [01:57.30] = 60 + 57.30 = 117.30 + 1.5
                    ),
                    LyricSection(
                        title: "Chorus 2",
                        fullText: "When you feel my heat look into my eyes it's where my demons hide it's where my demons hide don't get too close it's dark inside it's where my demons hide it's where my demons hide",
                        missingWords: ["heat", "eyes", "dark"],
                        candidateWords: ["heat", "eyes", "dark", "cold", "soul", "light", "warm", "heart", "bright"],
                        startTime: 120.80, // [02:00.80] = 120 + 0.80 = 120.80
                        endTime: 143.30 // [02:18.80] = 120 + 18.80 = 138.80 + 1.5
                    ),
                    LyricSection(
                        title: "Bridge & Final Chorus",
                        fullText: "They say it's what you make I say it's up to fate it's woven in my soul I need to let you go your eyes they shine so bright I wanna save that light I can't escape this now unless you show me how when you feel my heat look into my eyes it's where my demons hide it's where my demons hide don't get too close it's dark inside it's where my demons hide it's where my demons hide",
                        missingWords: ["fate", "soul", "light"],
                        candidateWords: ["fate", "soul", "light", "luck", "heart", "dark", "chance", "mind", "bright"],
                        startTime: 141.70, // [02:21.70] = 120 + 21.70 = 141.70
                        endTime: 185.00 // [03:01.50] = 180 + 1.50 = 181.50 + 1.5
                    )
                ]
            ),
            Song(
                id: tooGoodAtGoodbyesId,
                title: "Too Good At Goodbyes",
                artist: "Sam Smith",
                difficulty: .advanced,
                coverImageName: "samsmith",
                duration: 243, // ~4 minutes
                audioFileName: "Sam Smith - Too Good At Goodbyes.mp3",
                sections: [
                    LyricSection(
                        title: "Verse 1 & Pre-Chorus",
                        fullText: "You must think that I'm stupid you must think that I'm a fool you must think that I'm new to this but I have seen this all before I'm never gonna let you close to me even though you mean the most to me cause every time I open up it hurts so I'm never gonna get too close to you even when I mean the most to you in case you go and leave me in the dirt",
                        missingWords: ["stupid", "close", "dirt"],
                        candidateWords: ["stupid", "close", "dirt", "smart", "far", "clean", "clever", "near", "ground"],
                        startTime: 47.60, // [00:47.60] = 47.60
                        endTime: 88.70 // [01:27.20] = 60 + 27.20 = 87.20 + 1.5
                    ),
                    LyricSection(
                        title: "Chorus 1",
                        fullText: "Every time you hurt me the less that I cry and every time you leave me the quicker these tears dry and every time you walk out the less I love you baby we don't stand a chance it's sad but it's true I'm way too good at goodbyes I'm way too good at goodbyes I'm way too good at goodbyes I'm way too good at goodbyes",
                        missingWords: ["hurt", "leave", "goodbyes"],
                        candidateWords: ["hurt", "leave", "goodbyes", "love", "stay", "hellos", "help", "go", "greetings"],
                        startTime: 87.20, // [01:27.20] = 60 + 27.20 = 87.20
                        endTime: 119.80 // [02:00.30] = 120 + 0.30 = 120.30 + 1.5
                    ),
                    LyricSection(
                        title: "Verse 2 & Pre-Chorus",
                        fullText: "I know you're thinking I'm heartless I know you're thinking I'm cold I'm just protecting my innocence I'm just protecting my soul I'm never gonna let you close to me even though you mean the most to me cause every time I open up it hurts so I'm never gonna get too close to you even when I mean the most to you in case you go and leave me in the dirt",
                        missingWords: ["heartless", "soul", "close"],
                        candidateWords: ["heartless", "soul", "close", "kind", "heart", "far", "cold", "mind", "near"],
                        startTime: 120.30, // [02:00.30] = 120 + 0.30 = 120.30
                        endTime: 160.80 // [02:40.30] = 120 + 40.30 = 160.30 + 1.5
                    ),
                    LyricSection(
                        title: "Chorus 2 & Bridge",
                        fullText: "Every time you hurt me the less that I cry and every time you leave me the quicker these tears dry and every time you walk out the less I love you baby we don't stand a chance it's sad but it's true I'm way too good at goodbyes I'm way too good at goodbyes I'm way too good at goodbyes I'm way too good at goodbyes no way that you'll see me cry no way that you'll see me cry I'm way too good at goodbyes I'm way too good at goodbyes no no no ",
                        missingWords: ["hurt", "cry", "no"],
                        candidateWords: ["hurt", "cry", "no", "love", "laugh", "yes", "help", "smile", "maybe"],
                        startTime: 160.30, // [02:40.30] = 120 + 40.30 = 160.30
                        endTime: 220.00 // [03:42.50] = 180 + 42.50 = 222.50 + 1.5
                    ),
                    LyricSection(
                        title: "Final Chorus",
                        fullText: "Cause every time you hurt me the less that I cry and every time you leave me the quicker these tears dry and every time you walk out the less I love you baby we don't stand a chance it's sad but it's true I'm way too good at goodbyes",
                        missingWords: ["hurt", "leave", "goodbyes"],
                        candidateWords: ["hurt", "leave", "goodbyes", "love", "stay", "hellos", "help", "go", "greetings"],
                        startTime: 222.50, // [03:42.50] = 180 + 42.50 = 222.50
                        endTime: 247.40 // [04:02.90] = 240 + 2.90 = 242.90 + 1.5
                    )
                ]
            ),
            Song(
                id: arabellaId,
                title: "Arabella",
                artist: "Arctic Monkeys",
                difficulty: .intermediate,
                coverImageName: "ArcticMonkeys",
                duration: 227, // ~3.8 minutes
                audioFileName: "Arctic Monkeys - Arabella (Official Video).mp3",
                sections: [
                    LyricSection(
                        title: "Verse 1",
                        fullText: "Arabella's got some interstellagator skin boots and a helter skelter around her little finger and I ride it endlessly she's got a Barbarella silver swimsuit and when she needs a shelter from reality she takes a dip in my daydreams",
                        missingWords: ["boots", "swimsuit", "daydreams"],
                        candidateWords: ["boots", "swimsuit", "daydreams", "shoes", "dress", "dreams", "heels", "suit", "thoughts"],
                        startTime: 48.00, // [00:48.00] Arabella's got some interstellagator skin boots
                        endTime: 112.80 // [01:11.30] - 1.5 = My days end best (bitiş 1.5 saniye sonra)
                    ),
                    LyricSection(
                        title: "Chorus 1",
                        fullText: "My days end best when this sunset gets itself behind that little lady sitting on the passenger side it's much less picturesque without her catching the light the horizon tries but it's just not as kind on the eyes as Arabella oh as Arabella just might have tapped into your mind and soul you can't be sure",
                        missingWords: ["sunset", "light", "Arabella"],
                        candidateWords: ["sunset", "light", "Arabella", "sunrise", "dark", "Bella", "dawn", "bright", "girl"],
                        startTime: 71.30, // [01:11.30] = 60 + 11.30 = 71.30
                        endTime: 123.80 // [02:03.30] = 120 + 3.30 = 123.30 + 1.5
                    ),
                    LyricSection(
                        title: "Verse 2",
                        fullText: "Arabella's got a 70s head but she's a modern lover it's an exploration she's made of outer space and her lips are like the galaxy's edge and a kiss the colour of a constellation falling into place",
                        missingWords: ["head", "space", "place"],
                        candidateWords: ["head", "space", "place", "mind", "time", "space", "soul", "earth", "face"],
                        startTime: 123.30, // [02:03.30] = 120 + 3.30 = 123.30
                        endTime: 147.50 // [02:26.00] = 120 + 26.00 = 146.00 + 1.5
                    ),
                    LyricSection(
                        title: "Chorus 2",
                        fullText: "My days end best when this sunset gets itself behind that little lady sitting on the passenger side it's much less picturesque without her catching the light the horizon tries but it's just not as kind on the eyes as Arabella oh as Arabella just might have tapped into your mind and soul you can't be sure",
                        missingWords: ["sunset", "light", "soul"],
                        candidateWords: ["sunset", "light", "soul", "sunrise", "dark", "heart", "dawn", "bright", "mind"],
                        startTime: 146.00, // [02:26.00] = 120 + 26.00 = 146.00
                        endTime: 188.50 // [03:08.00] = 180 + 8.00 = 188.00 + 1.5
                    ),
                    LyricSection(
                        title: "Bridge & Outro",
                        fullText: "That's magic in a cheetah print coat just a slip underneath it I hope asking if I can have one of those organic cigarettes that she smokes wraps her lips round the Mexican coke makes you wish that you were the bottle takes a sip of your soul and it sounds like just might have tapped into your mind and soul you can't be sure",
                        missingWords: ["magic", "cigarettes", "soul"],
                        candidateWords: ["magic", "cigarettes", "soul", "power", "smoke", "heart", "charm", "drink", "mind"],
                        startTime: 188.00, // [03:08.00] = 180 + 8.00 = 188.00
                        endTime: 228.50 // [03:47.00] = 180 + 47.00 = 227.00 + 1.5
                    )
                ]
            ),
        ]
    }
}

