import Foundation
import SwiftUI

/// Manager for game scores and persistence
class ScoreManager {
    
    /// Current game score
    private(set) var score: Int = 0
    
    /// High score from previous games
    private(set) var highScore: Int
    
    /// Highest level player has reached
    private(set) var highestLevelReached: Int
    
    /// Score when player last continued
    private(set) var continuationScore: Int
    
    /// Last level player completed
    private(set) var lastPlayedLevel: Int
    
    /// Initialize score manager with values from UserDefaults
    init() {
        self.highScore = UserDefaults.standard.integer(forKey: Constants.UserDefaultsKeys.highScore)
        self.highestLevelReached = UserDefaults.standard.integer(forKey: Constants.UserDefaultsKeys.highestLevel)
        self.continuationScore = UserDefaults.standard.integer(forKey: Constants.UserDefaultsKeys.continuationScore)
        self.lastPlayedLevel = UserDefaults.standard.integer(forKey: Constants.UserDefaultsKeys.lastPlayedLevel)
        
        // Initialize defaults if needed
        if self.highestLevelReached == 0 {
            self.highestLevelReached = 1
        }
        if self.lastPlayedLevel == 0 {
            self.lastPlayedLevel = 1
        }
    }
    
    /// Add points for collecting a vegetable
    func addScore(for color: CircleColor) {
        if color == .bomb {
            decreaseScore()
        } else {
            increaseScore()
        }
    }
    
    /// Reset score to zero
    func resetScore() {
        score = 0
        saveContinuationScore(0)
    }
    
    /// Set score directly (for continuing games)
    func setScore(_ newScore: Int) {
        score = newScore
    }
    
    /// Update highest level reached
    func updateHighestLevel(_ level: Int) {
        if level > highestLevelReached {
            highestLevelReached = level
            UserDefaults.standard.set(highestLevelReached, forKey: Constants.UserDefaultsKeys.highestLevel)
        }
    }
    
    /// Save the current level as last played
    func saveLastPlayedLevel(_ level: Int) {
        lastPlayedLevel = level
        UserDefaults.standard.set(lastPlayedLevel, forKey: Constants.UserDefaultsKeys.lastPlayedLevel)
    }
    
    /// Save current score for game continuation
    func saveContinuationScore(_ continuationScore: Int = -1) {
        self.continuationScore = continuationScore >= 0 ? continuationScore : score
        UserDefaults.standard.set(self.continuationScore, forKey: Constants.UserDefaultsKeys.continuationScore)
    }
    
    // MARK: - Private Methods
    
    /// Increment score for collecting a vegetable
    private func increaseScore() {
        score += Constants.Game.vegetableScoreValue
        updateHighScore()
    }
    
    /// Decrement score for hitting a bomb
    private func decreaseScore() {
        score = max(0, score - Constants.Game.bombScorePenalty)
    }
    
    /// Update high score if needed
    private func updateHighScore() {
        if score > highScore {
            highScore = score
            UserDefaults.standard.set(highScore, forKey: Constants.UserDefaultsKeys.highScore)
        }
    }
} 