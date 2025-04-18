import SwiftUI
import Combine

/// Main class managing the overall game state
class GameState: ObservableObject {
    // MARK: - Published Properties
    
    /// Circles currently in play
    @Published var circles: [GameCircle] = []
    
    /// Game state flags
    @Published var isGameOver: Bool = false
    @Published var isPaused: Bool = false
    @Published var isHomeScreen: Bool = true
    @Published var isLevelComplete: Bool = false
    
    /// Visual effect flags
    @Published var showBombEffect: Bool = false
    @Published var screenShakeOffset: CGSize = .zero
    
    // MARK: - Managers
    
    /// Manager for level progression
    private(set) var levelManager: LevelManager
    
    /// Manager for score tracking
    private(set) var scoreManager: ScoreManager
    
    /// Manager for player lives
    private(set) var lifeManager: LifeManager
    
    // MARK: - Computed Properties
    
    /// Current level number
    var level: Int {
        levelManager.currentLevel
    }
    
    /// Current score
    var score: Int {
        scoreManager.score
    }
    
    /// High score from previous games
    var highScore: Int {
        scoreManager.highScore
    }
    
    /// Remaining player lives
    var remainingLives: Int {
        lifeManager.remainingLives
    }
    
    /// Number of items to collect to complete level
    var targetCount: Int {
        levelManager.targetCount
    }
    
    /// Background image for current level
    var levelBackground: String {
        levelManager.background
    }
    
    /// Current game speed
    var currentSpeed: Double {
        levelManager.speedForCurrentLevel
    }
    
    /// Vegetables selected for current level
    var currentLevelVegetables: [CircleColor] {
        levelManager.levelVegetables
    }
    
    /// Current collection counts for vegetables
    var vegetableCounts: [CircleColor: Int] {
        levelManager.vegetableCounts
    }
    
    /// Flag indicating if life loss effect should be shown
    var showLifeLossEffect: Bool {
        get { lifeManager.isShowingLifeLossEffect }
        set { lifeManager.isShowingLifeLossEffect = newValue }
    }
    
    /// Flag indicating if missed vegetable warning should be shown
    var showMissedWarning: Bool {
        get { lifeManager.isShowingMissedWarning }
        set { lifeManager.isShowingMissedWarning = newValue }
    }
    
    /// Counter for missed vegetables
    var missedVegetablesCount: Int {
        lifeManager.missedVegetablesCount
    }
    
    /// Highest level the player has reached
    var highestLevelReached: Int {
        scoreManager.highestLevelReached
    }
    
    /// Last level completed
    var lastPlayedLevel: Int {
        scoreManager.lastPlayedLevel
    }
    
    /// Score when player last continued
    var continuationScore: Int {
        scoreManager.continuationScore
    }
    
    /// Counter for spawn intervals
    var spawnCounter: Int = 0
    
    // MARK: - Initialization
    
    init() {
        self.levelManager = LevelManager()
        self.scoreManager = ScoreManager()
        self.lifeManager = LifeManager()
        self.isHomeScreen = true
    }
    
    // MARK: - Game Flow Methods
    
    /// Reset the game to initial state
    func resetGame() {
        // Reset managers
        levelManager = LevelManager(startingLevel: 1)
        scoreManager.resetScore()
        lifeManager.resetLives()
        
        // Reset game state
        circles = []
        isGameOver = false
        isPaused = false
        isLevelComplete = false
        showBombEffect = false
        spawnCounter = 0
        
        // Reset UserDefaults
        UserDefaults.standard.set(1, forKey: Constants.UserDefaultsKeys.lastPlayedLevel)
        UserDefaults.standard.set(0, forKey: Constants.UserDefaultsKeys.continuationScore)
        
        // Restart music
        SoundManager.shared.stopAllSounds()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            SoundManager.shared.playBackgroundMusic(Constants.Sounds.gamePlay)
        }
    }
    
    /// Start the game from home screen
    func startGameFromHome() {
        resetGame()
        isHomeScreen = false
        SoundManager.shared.stopBackgroundMusic()
        SoundManager.shared.playBackgroundMusic(Constants.Sounds.gamePlay)
    }
    
    /// Continue a previously saved game
    func continueGame() {
        // Get saved values
        let lastLevel = scoreManager.lastPlayedLevel
        let savedScore = scoreManager.continuationScore
        let savedLives = lifeManager.remainingLives
        
        print("DEBUG: continueGame - lastLevel = \(lastLevel), savedScore = \(savedScore), savedLives = \(savedLives)")
        
        // Reset game but preserve progress
        resetGame()
        
        // Restore saved values
        scoreManager.setScore(savedScore)
        levelManager.setLevel(lastLevel + 1) // Continue at next level
        lifeManager.setLives(savedLives)
        
        print("DEBUG: continueGame - Set level to \(levelManager.currentLevel)")
        
        // Start the continued game
        isHomeScreen = false
        SoundManager.shared.stopAllSounds()
        SoundManager.shared.playBackgroundMusic(Constants.Sounds.gamePlay)
    }
    
    /// Register when the player misses a vegetable
    func missVegetable() {
        let lifeLost = lifeManager.registerMissedVegetable()
        
        // Play miss sound
        SoundManager.shared.playSound(Constants.Sounds.levelFail)
        
        // Handle life loss
        if lifeLost {
            let isGameOver = lifeManager.remainingLives <= 0
            
            if isGameOver {
                self.isGameOver = true
                SoundManager.shared.stopAllSounds()
                SoundManager.shared.playSound(Constants.Sounds.levelFail)
            }
            
            // Show screen shake
            addScreenShakeAnimation()
        }
        
        // Auto-hide warning after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.UI.missWarningDuration) {
            self.lifeManager.hideEffects()
        }
    }
    
    /// Add score for collecting a vegetable
    func addScore(for color: CircleColor) {
        // Update score
        scoreManager.addScore(for: color)
        
        // For regular vegetables, update the collection count
        if color != .bomb {
            levelManager.collectVegetable(color)
            
            // Check if level is complete
            let levelComplete = levelManager.isLevelComplete()
            if levelComplete {
                self.isLevelComplete = true
                SoundManager.shared.stopAllSounds()
                SoundManager.shared.playSound(Constants.Sounds.levelWin)
            }
        } else {
            // Show bomb effect
            showBombEffect = true
            addScreenShakeAnimation()
            
            // Hide bomb effect after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.showBombEffect = false
            }
        }
    }
    
    /// Advance to the next level
    func startNextLevel() {
        // Save current progress
        scoreManager.saveLastPlayedLevel(levelManager.currentLevel)
        scoreManager.saveContinuationScore()
        
        // Debug lastPlayedLevel
        print("DEBUG: Saved lastPlayedLevel = \(levelManager.currentLevel)")
        
        // Advance to next level
        levelManager.advanceToNextLevel()
        
        // Update highest level reached
        scoreManager.updateHighestLevel(levelManager.currentLevel)
        
        // Add bonus life
        let lifeAdded = lifeManager.addLife()
        if lifeAdded {
            SoundManager.shared.playSound(Constants.Sounds.gameBonus)
        }
        
        // Reset game state for new level
        circles = []
        isLevelComplete = false
        isPaused = false
        spawnCounter = 0
        
        // Start music for new level
        SoundManager.shared.stopAllSounds()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            SoundManager.shared.playBackgroundMusic(Constants.Sounds.gamePlay)
        }
    }
    
    /// Return to home screen
    func goToHome() {
        // Save game state
        if !isGameOver {
            print("DEBUG: goToHome - Saving lastPlayedLevel = \(levelManager.currentLevel)")
            
            // Fix: Ensure the level is properly saved even after level completion
            // This is critical for the continue button to appear
            let levelToSave = isLevelComplete ? levelManager.currentLevel : levelManager.currentLevel
            scoreManager.saveLastPlayedLevel(levelToSave)
            scoreManager.saveContinuationScore()
            
            // Force UserDefaults to synchronize
            UserDefaults.standard.synchronize()
        } else {
            // Reset progress if game over
            print("DEBUG: goToHome - Game over, resetting progress")
            scoreManager.saveContinuationScore(0)
            scoreManager.saveLastPlayedLevel(1)
            lifeManager.resetLives()
            
            // Force UserDefaults to synchronize
            UserDefaults.standard.synchronize()
        }
        
        // Update game state
        circles = []
        isHomeScreen = true
        isPaused = false
        isGameOver = false
        
        // Stop all sounds
        SoundManager.shared.stopAllSounds()
        
        // Play home music if enabled
        if UserDefaults.standard.bool(forKey: Constants.UserDefaultsKeys.isMusicEnabled) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                SoundManager.shared.playBackgroundMusic(Constants.Sounds.gameHome)
            }
        }
    }
    
    /// Stop the game (clear circles)
    func stopGame() {
        circles = []
    }
    
    // MARK: - Helper Methods
    
    /// Add screen shake animation when life is lost
    private func addScreenShakeAnimation() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
        
        withAnimation(.easeInOut(duration: 0.1).repeatCount(5)) {
            screenShakeOffset = CGSize(width: 15, height: 0)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: 0.1)) {
                self.screenShakeOffset = .zero
            }
        }
    }
} 