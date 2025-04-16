import Foundation
import SwiftUI

/// Manager for level-related logic and progression
class LevelManager {
    
    /// Current level
    private(set) var currentLevel: Int
    
    /// Required vegetables to complete the level
    private(set) var targetCount: Int
    
    /// Background image for current level
    private(set) var background: String
    
    /// Selected vegetables for the current level
    private(set) var levelVegetables: [CircleColor] = []
    
    /// Current level's vegetable collection counts
    private(set) var vegetableCounts: [CircleColor: Int] = [:]
    
    /// Determines how frequently bombs appear
    var bombFrequency: Int {
        return max(12 - currentLevel, 6)
    }
    
    /// Initialize a new level manager
    init(startingLevel: Int = 1) {
        // Initialize stored properties directly without calling methods
        self.currentLevel = startingLevel
        
        // Set target count based on level
        if startingLevel <= 3 {
            self.targetCount = 4
        } else if startingLevel <= 7 {
            self.targetCount = 5
        } else {
            self.targetCount = 6
        }
        
        // Set background image
        let backgroundNumber = ((startingLevel - 1) % 7) + 1
        self.background = "gameplay_background\(backgroundNumber)"
        
        // Now that all properties are initialized, we can call methods
        selectVegetablesForLevel()
    }
    
    /// Calculate speed for the current level
    var speedForCurrentLevel: Double {
        return min(
            Constants.Game.initialSpeed + (Double(currentLevel - 1) * Constants.Game.speedIncrement),
            Constants.Game.maxSpeed
        )
    }
    
    /// Advance to the next level
    func advanceToNextLevel() -> Bool {
        currentLevel += 1
        targetCount = calculateTargetCount(for: currentLevel)
        background = calculateBackground(for: currentLevel)
        selectVegetablesForLevel()
        return true
    }
    
    /// Reset the current level
    func resetCurrentLevel() {
        resetVegetableCounts()
    }
    
    /// Set the level directly (for continuing saved games)
    func setLevel(_ level: Int) {
        currentLevel = max(1, level)
        targetCount = calculateTargetCount(for: currentLevel)
        background = calculateBackground(for: currentLevel)
        selectVegetablesForLevel()
    }
    
    /// Check if a vegetable has been collected
    func collectVegetable(_ color: CircleColor) {
        guard color.isVegetable else { return }
        
        vegetableCounts[color, default: 0] += 1
    }
    
    /// Determine if the level is complete
    func isLevelComplete() -> Bool {
        return levelVegetables
            .filter { $0.isVegetable }
            .allSatisfy { (vegetableCounts[$0] ?? 0) >= targetCount }
    }
    
    // MARK: - Private Methods
    
    /// Reset the vegetable counts for the current level
    private func resetVegetableCounts() {
        vegetableCounts = Dictionary(
            uniqueKeysWithValues: levelVegetables
                .filter { $0.isVegetable }
                .map { ($0, 0) }
        )
    }
    
    /// Select vegetables for the current level
    private func selectVegetablesForLevel() {
        let availableVegetables = CircleColor.allCases.filter { $0.isVegetable }
        var selectedVegetables = Array(availableVegetables.shuffled().prefix(4))
        
        // Ensure we have exactly 4 vegetables
        while selectedVegetables.count < 4 {
            if let vegetable = availableVegetables.randomElement() {
                if !selectedVegetables.contains(vegetable) {
                    selectedVegetables.append(vegetable)
                }
            }
        }
        
        // Always add bomb to available colors
        selectedVegetables.append(.bomb)
        levelVegetables = selectedVegetables
        
        // Initialize counts
        resetVegetableCounts()
    }
    
    /// Calculate target count based on level
    private func calculateTargetCount(for level: Int) -> Int {
        if level <= 3 {
            return 4
        } else if level <= 7 {
            return 5
        } else {
            return 6
        }
    }
    
    /// Calculate background image for level
    private func calculateBackground(for level: Int) -> String {
        let backgroundNumber = ((level - 1) % 7) + 1
        return "gameplay_background\(backgroundNumber)"
    }
} 