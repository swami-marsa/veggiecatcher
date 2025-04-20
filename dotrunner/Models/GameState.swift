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
    
    // MARK: - Timer Properties
    
    /// Timer for animating falling circles
    private var fallingTimer: Timer?
    
    /// Timer for spawning new circles
    private var spawningTimer: Timer?
    
    /// Timer for hiding warning messages
    private var warningTimer: Timer?
    
    /// Timestamp for last game update
    private var lastUpdateTime: Date = Date()
    
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
        print("DEBUG: Continuing game from lives reward")
        
        // Get the saved level
        let savedLevel = scoreManager.lastPlayedLevel
        print("DEBUG: Continuing from saved level: \(savedLevel)")
        
        // Get the saved score
        let savedScore = scoreManager.continuationScore
        print("DEBUG: Continuing with saved score: \(savedScore)")
        
        // Create a new level manager with the correct level
        // Important: When continuing, we use the saved level + 1
        // This matches the UI that shows "Level \(max(2, gameState.lastPlayedLevel + 1))"
        let continueLevel = max(2, savedLevel + 1)
        self.levelManager = LevelManager(startingLevel: continueLevel)
        
        // Restore the saved score
        scoreManager.setScore(savedScore)
        
        // Update score manager to match the continued level
        scoreManager.updateHighestLevel(continueLevel)
        
        // Reset lives
        self.lifeManager.resetLives()
        self.isGameOver = false
        self.isPaused = false
        
        // CRITICAL: Ensure level complete is set to false
        // Otherwise the game will show the level complete screen incorrectly
        self.isLevelComplete = false
        
        // Ensure we properly reset all falling vegetables state
        self.circles = []
        
        // Reset all timers to ensure proper game flow
        cancelAllTimers()
        
        // Restart the game timers and systems
        startFallingTimer()
        startSpawningTimer()
        
        // Make sure all time-based systems are ready
        self.lastUpdateTime = Date()
        
        // Reset warning display
        self.showMissedWarning = false
        lifeManager.resetMissedVegetablesCount()
        
        // Debug current state
        print("DEBUG: Game continued with level: \(levelManager.currentLevel) and score: \(scoreManager.score)")
    }
    
    private func cancelAllTimers() {
        fallingTimer?.invalidate()
        fallingTimer = nil
        
        spawningTimer?.invalidate()
        spawningTimer = nil
        
        warningTimer?.invalidate()
        warningTimer = nil
    }
    
    /// Start the falling animation timer
    private func startFallingTimer() {
        fallingTimer?.invalidate()
        
        fallingTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { [weak self] _ in
            guard let self = self, !self.isPaused && !self.isGameOver && !self.isLevelComplete else { return }
            
            // Update falling animations
            self.updateFallingCircles()
        }
        
        RunLoop.current.add(fallingTimer!, forMode: .common)
    }
    
    /// Start the circle spawning timer
    private func startSpawningTimer() {
        spawningTimer?.invalidate()
        
        // Adjust spawn interval based on level
        let baseInterval = max(1.3 - (Double(level) * 0.05), 0.6)
        
        spawningTimer = Timer.scheduledTimer(withTimeInterval: baseInterval, repeats: true) { [weak self] _ in
            guard let self = self, !self.isPaused && !self.isGameOver && !self.isLevelComplete else { return }
            
            // Spawn new circles
            self.spawnCircle()
        }
        
        RunLoop.current.add(spawningTimer!, forMode: .common)
    }
    
    /// Update falling circles positions
    private func updateFallingCircles() {
        // Implement falling logic if needed
        // This stub is here to satisfy the method call
    }
    
    /// Spawn a new circle
    private func spawnCircle() {
        // Implement spawning logic if needed
        // This stub is here to satisfy the method call
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
    
    /// Refill all lives to maximum (5)
    func refillAllLives() {
        // Set lives to maximum
        lifeManager.setLives(5)
        
        // Play regeneration sound if available
        SoundManager.shared.playSound("powerup")
        
        // Log the lives now available
        print("Lives refilled to maximum (5). Current lives: \(lifeManager.remainingLives)")
        
        // If we're in game over state, we need to reset the game state to continue
        if isGameOver {
            print("Resetting game state to continue after game over")
            
            // Reset game state but preserve level and score
            circles = []
            spawnCounter = 0
            
            // Reset vegetable counters
            levelManager.resetVegetableCounters()
            
            // Make sure current level and score are preserved
            let currentLevel = levelManager.currentLevel
            let currentScore = scoreManager.score
            print("Preserving level: \(currentLevel), score: \(currentScore)")
            
            // Save state to UserDefaults
            scoreManager.saveLastPlayedLevel(currentLevel)
            scoreManager.saveContinuationScore(currentScore)
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
        print("DEBUG: startNextLevel - Saved lastPlayedLevel = \(levelManager.currentLevel)")
        
        // Advance to next level
        levelManager.advanceToNextLevel()
        
        // Debug - confirm new level
        print("DEBUG: startNextLevel - Advanced to level \(levelManager.currentLevel)")
        
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
            print("DEBUG: goToHome - Original level = \(levelManager.currentLevel), isLevelComplete = \(isLevelComplete)")
            
            // Logic for saving the level:
            // 1. If we're coming from a completed level, save the current level
            // 2. Otherwise, save current level minus 1 (because continue will add 1)
            // This ensures Continue button shows the correct next level
            let levelToSave = isLevelComplete ? levelManager.currentLevel : levelManager.currentLevel - 1
            
            // Make sure we don't save a level below 1
            let safeLevelToSave = max(1, levelToSave)
            
            print("DEBUG: goToHome - Saving lastPlayedLevel = \(safeLevelToSave)")
            scoreManager.saveLastPlayedLevel(safeLevelToSave)
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
        isLevelComplete = false  // Make sure to reset the level complete flag
        
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