import Foundation
import SwiftUI

/// Manager for player lives and missed vegetable tracking
class LifeManager {
    
    /// Current number of player lives
    private(set) var remainingLives: Int
    
    /// Counter for missed vegetables before life loss
    private(set) var missedVegetablesCount: Int = 0
    
    /// Flag indicating life loss animation state
    var isShowingLifeLossEffect: Bool = false
    
    /// Flag indicating missed vegetable warning state
    var isShowingMissedWarning: Bool = false
    
    /// Initialize life manager
    init() {
        let savedLives = UserDefaults.standard.integer(forKey: Constants.UserDefaultsKeys.remainingLives)
        self.remainingLives = savedLives > 0 ? savedLives : Constants.Game.initialLives
    }
    
    /// Register a missed vegetable, lose life if threshold exceeded
    /// - Returns: Bool indicating if a life was lost
    func registerMissedVegetable() -> Bool {
        missedVegetablesCount += 1
        isShowingMissedWarning = true
        
        // Check if exceeded threshold for life loss
        if missedVegetablesCount >= Constants.Game.missesToLoseLife {
            loseLife()
            missedVegetablesCount = 0
            return true
        }
        
        return false
    }
    
    /// Lose a life
    /// - Returns: Bool indicating if player is out of lives (game over)
    func loseLife() -> Bool {
        isShowingLifeLossEffect = true
        remainingLives -= 1
        saveLives()
        return remainingLives <= 0
    }
    
    /// Add a bonus life
    /// - Returns: Bool indicating if life was added or already at max
    func addLife() -> Bool {
        if remainingLives < Constants.Game.maxLives {
            remainingLives += 1
            saveLives()
            return true
        }
        return false
    }
    
    /// Reset life counter to initial value
    func resetLives() {
        remainingLives = Constants.Game.initialLives
        missedVegetablesCount = 0
        isShowingLifeLossEffect = false
        isShowingMissedWarning = false
        saveLives()
    }
    
    /// Reset missed vegetable counter to zero
    func resetMissedVegetablesCount() {
        missedVegetablesCount = 0
        isShowingMissedWarning = false
    }
    
    /// Set exact number of lives (for continuing games)
    func setLives(_ lives: Int) {
        remainingLives = max(0, min(lives, Constants.Game.maxLives))
        saveLives()
    }
    
    /// Hide visual effects
    func hideEffects() {
        isShowingLifeLossEffect = false
        isShowingMissedWarning = false
    }
    
    /// Get remaining chances before life loss
    var remainingChances: Int {
        return Constants.Game.missesToLoseLife - missedVegetablesCount
    }
    
    // MARK: - Private Methods
    
    /// Save lives to UserDefaults
    private func saveLives() {
        UserDefaults.standard.set(remainingLives, forKey: Constants.UserDefaultsKeys.remainingLives)
    }
} 