import SwiftUI

/// Constants used throughout the application
enum Constants {
    
    /// Game mechanics related constants
    enum Game {
        static let initialLives = 5
        static let initialSpeed = 3.0
        static let maxSpeed = 8.0
        static let speedIncrement = 0.5
        static let bombSpawnIntervalBase = 8
        static let missesToLoseLife = 3
        static let bombScorePenalty = 20
        static let vegetableScoreValue = 10
        static let maxLives = 5
    }
    
    /// UI-related constants
    enum UI {
        static let standardCircleSize: CGFloat = 80
        static let bombSize: CGFloat = 70
        static let beetrootSize: CGFloat = 90
        static let splashScreenDuration = 3.5
        static let missWarningDuration = 1.5
        static let lifeLossEffectDuration = 0.3
        static let bonusLifeSoundDelay = 0.5
    }
    
    /// UserDefaults keys
    enum UserDefaultsKeys {
        static let highScore = "HighScore"
        static let isMusicEnabled = "isMusicEnabled"
        static let remainingLives = "RemainingLives"
        static let highestLevel = "HighestLevel"
        static let lastPlayedLevel = "LastPlayedLevel"
        static let continuationScore = "ContinuationScore"
    }
    
    /// Sound names
    enum Sounds {
        static let swipe = "swipe"
        static let bombTick = "bombtick"
        static let explosion = "explosion"
        static let gameHome = "game_home"
        static let gamePlay = "game_play"
        static let gameBonus = "gamebonus"
        static let levelFail = "levelfail"
        static let levelWin = "levelwin"
    }
} 