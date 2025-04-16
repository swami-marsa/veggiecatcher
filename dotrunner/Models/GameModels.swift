import SwiftUI
import Foundation

// Game circle model
struct GameCircle: Identifiable, Equatable {
    let id = UUID()
    var color: CircleColor
    var position: CGPoint
    var scale: CGFloat = 1.0
    var opacity: Double = 1.0
    
    // Implement Equatable
    static func == (lhs: GameCircle, rhs: GameCircle) -> Bool {
        return lhs.id == rhs.id &&
               lhs.color == rhs.color &&
               lhs.position == rhs.position &&
               lhs.scale == rhs.scale &&
               lhs.opacity == rhs.opacity
    }
}

// Available circle colors
enum CircleColor: String, CaseIterable {
    case carrot, broccoli, corn, potato  // Original vegetables
    case beetroot, bottlegaurd, brinjal, cabbage
    case califlower, cucumber, mango, onion
    case bomb // Renamed from red to bomb for clarity
    
    var vegetableImage: String {
        switch self {
        case .bomb: return "red-broccoli"  // Keep bomb as red broccoli
        default: return rawValue // Use the enum case name as image name
        }
    }
    
    var color: Color {
        switch self {
        case .carrot: return .orange
        case .broccoli: return .green
        case .corn: return .yellow
        case .potato: return .brown
        case .beetroot: return .red
        case .bottlegaurd: return .green
        case .brinjal: return .purple
        case .cabbage: return .green
        case .califlower: return .white
        case .cucumber: return .green
        case .mango: return .yellow
        case .onion: return .purple
        case .bomb: return .red
        }
    }
    
    var gradientColors: [Color] {
        switch self {
        case .carrot: return [.orange, .red]
        case .broccoli: return [.green, .teal]
        case .corn: return [.yellow, .orange]
        case .potato: return [.brown, .orange]
        case .beetroot: return [.red, .purple]
        case .bottlegaurd: return [.green, .mint]
        case .brinjal: return [.purple, .indigo]
        case .cabbage: return [.green, .mint]
        case .califlower: return [.white, .gray]
        case .cucumber: return [.green, .mint]
        case .mango: return [.yellow, .orange]
        case .onion: return [.purple, .pink]
        case .bomb: return [.red, .orange]
        }
    }
}

// Add new PowerUpType enum
enum PowerUpType {
    case extraLife
    case slowDown
}

struct PowerUp: Identifiable {
    let id = UUID()
    let type: PowerUpType
    var position: CGPoint
    var scale: CGFloat = 1.0
    var opacity: Double = 1.0
}

// Game state management
class GameState: ObservableObject {
    // First, declare all stored properties
    @Published var targetCount: Int
    @Published var score: Int
    @Published var highScore: Int
    @Published var circles: [GameCircle]
    @Published var isGameOver: Bool
    @Published var isPaused: Bool
    @Published var remainingLives: Int
    @Published var isHomeScreen: Bool
    @Published var showBombEffect: Bool
    @Published var showLifeLossEffect: Bool
    @Published var isLevelComplete: Bool
    @Published var currentSpeed: Double
    @Published var level: Int
    @Published var spawnCounter: Int
    @Published var currentLevelVegetables: [CircleColor]
    @Published var vegetableCounts: [CircleColor: Int]
    @Published var screenShakeOffset: CGSize
    @Published var levelBackground: String
    @Published var missedVegetablesCount: Int
    @Published var showMissedWarning: Bool
    @Published var highestLevelReached: Int
    @Published var lastPlayedLevel: Int
    @Published var continuationScore: Int
    
    private let maxSpeed: Double = 8.0
    private let speedIncrement: Double = 0.5
    private let bombSpawnInterval = 8
    
    // Add new property for bomb frequency
    private var bombFrequency: Int {
        // More frequent bombs in higher levels
        return max(12 - level, 6)  // Starts at 11 for level 1, decreases to minimum 6
    }
    
    init() {
        // Initialize all stored properties first
        self.targetCount = 5
        self.score = 0
        self.highScore = UserDefaults.standard.integer(forKey: "HighScore")
        self.circles = []
        self.isGameOver = false
        self.isPaused = false
        self.remainingLives = UserDefaults.standard.integer(forKey: "RemainingLives")
        self.isHomeScreen = true
        self.showBombEffect = false
        self.showLifeLossEffect = false
        self.isLevelComplete = false
        self.currentSpeed = 3.0
        self.level = 1
        self.spawnCounter = 0
        self.currentLevelVegetables = []
        self.vegetableCounts = [:]
        self.screenShakeOffset = .zero
        self.levelBackground = "gameplay_background1"
        self.missedVegetablesCount = 0
        self.showMissedWarning = false
        self.highestLevelReached = UserDefaults.standard.integer(forKey: "HighestLevel")
        self.lastPlayedLevel = UserDefaults.standard.integer(forKey: "LastPlayedLevel")
        self.continuationScore = UserDefaults.standard.integer(forKey: "ContinuationScore")
        
        // After initialization, perform additional setup
        if self.highestLevelReached == 0 { 
            self.highestLevelReached = 1 
        }
        if self.lastPlayedLevel == 0 { 
            self.lastPlayedLevel = 1 
        }
        if self.remainingLives == 0 {
            self.remainingLives = 5
        }
        
        // Now we can safely call methods
        selectVegetablesForLevel()
    }
    
    // Add new method to select vegetables
    private func selectVegetablesForLevel() {
        let availableVegetables = CircleColor.allCases.filter { $0 != .bomb }
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
        currentLevelVegetables = selectedVegetables
        
        // Initialize counts for new vegetables (excluding bomb)
        vegetableCounts = Dictionary(uniqueKeysWithValues: 
            selectedVegetables.filter { $0 != .bomb }.map { ($0, 0) }
        )
    }
    
    func increaseSpeed() {
        currentSpeed = min(currentSpeed + speedIncrement, maxSpeed)
    }
    
    func resetGame() {
        // Always reset these values for new game
        score = 0
        continuationScore = 0
        level = 1  // Always start from level 1
        remainingLives = 5
        lastPlayedLevel = 1  // Reset last played level
        
        // Reset UserDefaults for new game
        UserDefaults.standard.set(5, forKey: "RemainingLives")
        UserDefaults.standard.set(1, forKey: "LastPlayedLevel")
        UserDefaults.standard.set(0, forKey: "ContinuationScore")
        
        // Reset other game states
        circles = []
        currentSpeed = 2.0
        spawnCounter = 0
        missedVegetablesCount = 0
        isGameOver = false
        isPaused = false
        isLevelComplete = false
        showMissedWarning = false
        showLifeLossEffect = false
        
        // Reset level-specific settings
        levelBackground = "gameplay_background1"
        selectVegetablesForLevel()
        resetCounters()
        
        // Ensure background music starts
        SoundManager.shared.stopAllSounds()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            SoundManager.shared.playBackgroundMusic("game_play")
        }
    }
    
    // Also update HomeScreen button action to ensure proper sound transition
    func startGameFromHome() {
        resetGame()
        SoundManager.shared.stopBackgroundMusic() // Stop home music
        SoundManager.shared.playBackgroundMusic("game_play") // Start game music immediately
    }
    
    func loseLife() {
        missedVegetablesCount += 1
        
        // Show warning animation
        withAnimation {
            showMissedWarning = true
        }
        
        // Hide warning after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                self.showMissedWarning = false
            }
        }
        
        // Only lose life after 3 misses
        if missedVegetablesCount >= 3 {
            missedVegetablesCount = 0 // Reset counter
            
            withAnimation(.easeInOut(duration: 0.3)) {
                remainingLives -= 1
                showLifeLossEffect = true
            }
            
            // Hide life loss effect after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation {
                    self.showLifeLossEffect = false
                }
            }
            
            if remainingLives <= 0 {
                SoundManager.shared.stopBackgroundMusic()  // Stop background music first
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    SoundManager.shared.playSound("levelfail")
                }
                isGameOver = true
                isPaused = true
                circles = []
                stopGame()
            }
        }
    }
    
    func goToHome() {
        // Save current game state before going home
        if !isGameOver {
            continuationScore = score
            lastPlayedLevel = level
            UserDefaults.standard.set(continuationScore, forKey: "ContinuationScore")
            UserDefaults.standard.set(lastPlayedLevel, forKey: "LastPlayedLevel")
            UserDefaults.standard.set(remainingLives, forKey: "RemainingLives")
            
            // Update high score if needed
            if score > highScore {
                highScore = score
                UserDefaults.standard.set(highScore, forKey: "HighScore")
            }
        } else {
            // Reset progress if game over
            continuationScore = 0
            lastPlayedLevel = 0
            remainingLives = 5
            UserDefaults.standard.set(0, forKey: "ContinuationScore")
            UserDefaults.standard.set(0, forKey: "LastPlayedLevel")
            UserDefaults.standard.set(5, forKey: "RemainingLives")
            // Don't reset high score on game over
        }
        
        stopGame()
        isHomeScreen = true
        isPaused = false
        isGameOver = false
        circles = []
        currentSpeed = 2.0
        spawnCounter = 0
        selectVegetablesForLevel()
        resetCounters()
        
        // Stop all sounds first
        SoundManager.shared.stopAllSounds()
        
        // Check if music is enabled before playing home music
        if UserDefaults.standard.bool(forKey: "isMusicEnabled") {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                SoundManager.shared.playBackgroundMusic("game_home")
            }
        }
    }
    
    func stopGame() {
        circles = []
    }
    
    func addScore(_ color: CircleColor) {
        if color == .bomb {
            score = max(0, score - 20)
        } else {
            score += 10
            if score > highScore {
                highScore = score
                UserDefaults.standard.set(highScore, forKey: "HighScore")
            }
            
            // Update vegetable count and check level completion
            if let currentCount = vegetableCounts[color] {
                vegetableCounts[color] = currentCount + 1
                
                // Check if level is complete
                checkLevelCompletion()
            }
        }
    }
    
    private func checkLevelCompletion() {
        let allTargetsMet = currentLevelVegetables
            .filter { $0 != .bomb }
            .allSatisfy { (vegetableCounts[$0] ?? 0) >= targetCount }
        
        if allTargetsMet {
            DispatchQueue.main.async {
                self.isLevelComplete = true
                SoundManager.shared.stopAllSounds()
                SoundManager.shared.playSound("levelwin")
            }
        }
    }
    
    func startNextLevel() {
        // Stop current level activities
        SoundManager.shared.stopAllSounds()
        
        // Save current level as last played level BEFORE incrementing
        lastPlayedLevel = level
        UserDefaults.standard.set(lastPlayedLevel, forKey: "LastPlayedLevel")
        
        // Update level and related states
        level += 1  // Increment current level
        
        // Update highest level reached if needed
        if level > highestLevelReached {
            highestLevelReached = level
            UserDefaults.standard.set(highestLevelReached, forKey: "HighestLevel")
        }
        
        // Add bonus life for completing level (max 5 lives)
        if remainingLives < 5 {
            remainingLives += 1
            UserDefaults.standard.set(remainingLives, forKey: "RemainingLives")
            // Play bonus sound
            SoundManager.shared.playSound("gamebonus")
        }
        
        // Save the current score
        continuationScore = score
        UserDefaults.standard.set(continuationScore, forKey: "ContinuationScore")
        
        // Reset level-specific states
        circles = []
        missedVegetablesCount = 0
        spawnCounter = 0
        isLevelComplete = false
        isPaused = false
        
        // Update background
        let backgroundNumber = ((level - 1) % 7) + 1
        levelBackground = "gameplay_background\(backgroundNumber)"
        
        // Update difficulty
        if level <= 3 {
            targetCount = 4
        } else if level <= 7 {
            targetCount = 5
        } else {
            targetCount = 6
        }
        
        // Update speed
        currentSpeed = min(3.0 + (Double(level - 1) * 0.5), maxSpeed)
        
        // Select new vegetables and reset counters
        selectVegetablesForLevel()
        resetCounters()
        
        // Play level transition sounds
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            SoundManager.shared.playBackgroundMusic("game_play")
        }
    }
    
    private func resetCounters() {
        vegetableCounts = Dictionary(uniqueKeysWithValues: 
            currentLevelVegetables.map { ($0, 0) }
        )
    }
    
    func missVegetable() {
        DispatchQueue.main.async {
            self.missedVegetablesCount += 1
            self.showMissedWarning = true
            
            // Play miss sound
            SoundManager.shared.playSound("levelfail")
            
            // Hide the warning after 1.5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.showMissedWarning = false
            }
            
            // Check if player has missed 3 vegetables
            if self.missedVegetablesCount >= 3 {
                self.missedVegetablesCount = 0
                self.remainingLives -= 1
                self.showLifeLossEffect = true
                
                // Reset the effect flag after animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.showLifeLossEffect = false
                }
                
                // Check for game over
                if self.remainingLives <= 0 {
                    self.isGameOver = true
                    SoundManager.shared.stopAllSounds()
                    SoundManager.shared.playSound("levelfail")
                }
            }
        }
    }
    
    func continueGame() {
        // Retrieve saved score and lives
        continuationScore = UserDefaults.standard.integer(forKey: "ContinuationScore")
        remainingLives = UserDefaults.standard.integer(forKey: "RemainingLives")
        lastPlayedLevel = UserDefaults.standard.integer(forKey: "LastPlayedLevel")
        
        // Reset game state but preserve score
        let savedScore = continuationScore  // Store score before reset
        resetGame()
        score = savedScore  // Restore score after reset
        
        // Set the correct level (lastPlayedLevel is the completed level)
        level = lastPlayedLevel + 1  // Start at the next level
        
        // Update game settings for the continued level
        let backgroundNumber = ((level - 1) % 7) + 1
        levelBackground = "gameplay_background\(backgroundNumber)"
        
        // Adjust difficulty based on level
        if level <= 3 {
            targetCount = 4
        } else if level <= 7 {
            targetCount = 5
        } else {
            targetCount = 6
        }
        
        currentSpeed = min(3.0 + (Double(level - 1) * 0.5), maxSpeed)
        selectVegetablesForLevel()
        
        // Start game music
        SoundManager.shared.stopAllSounds()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            SoundManager.shared.playBackgroundMusic("game_play")
        }
    }
} 