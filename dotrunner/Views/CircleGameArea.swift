import SwiftUI
import Foundation

struct CircleGameArea: View {
    @ObservedObject var gameState: GameState
    @State private var fallTimer: Timer?
    @State private var spawnTimer: Timer?
    @State private var missedVegetablePosition: CGPoint?
    @State private var showMissEffect = false
    @State private var showShockwave = false
    @State private var shockwavePosition: CGPoint = .zero
    @State private var showBombFlash = false
    private let deviceManager = DeviceManager.shared
    private let circleSize: CGFloat = 90
    
    private func getVegetableSize(_ color: CircleColor) -> CGFloat {
        switch color {
        case .bomb:
            return deviceManager.bombSize()
        case .beetroot:
            return deviceManager.beetrootSize()
        default:
            return deviceManager.standardVegetableSize()
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            let safeTop = geometry.safeAreaInsets.top
            
            ZStack {
                // Background
                Image(gameState.levelBackground)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: screenWidth, height: screenHeight)
                    .blur(radius: 1)
                    .opacity(0.9)
                    .clipped()
                
                // Red flash overlay for bomb hits
                if showBombFlash {
                    Color.red
                        .opacity(0.3)
                        .ignoresSafeArea()
                        .transition(.opacity)
                }
                
                // Game content
                VStack(spacing: 0) {
                    // Clear space for UI elements
                    Color.clear
                        .frame(height: safeTop + 80)
                    
                    // Additional spacing for progress bars
                    Color.clear
                        .frame(height: 60)
                    
                    // Missed vegetable warning
                    if gameState.showMissedWarning {
                        Text("Missed! \(3 - gameState.missedVegetablesCount) chances left")
                            .font(.system(size: deviceManager.missedWarningTextSize(), weight: .bold))
                            .foregroundColor(.red)
                            .padding(.horizontal, deviceManager.isIpad ? 24 : 16)
                            .padding(.vertical, deviceManager.isIpad ? 12 : 8)
                            .background(
                                RoundedRectangle(cornerRadius: deviceManager.isIpad ? 16 : 10)
                                    .fill(Color.black.opacity(0.7))
                                    .shadow(color: .black.opacity(0.3), radius: 5)
                            )
                            .transition(.scale.combined(with: .opacity))
                            .padding(.bottom, deviceManager.missedWarningPaddingBottom())
                    }
                    
                    // Game items container
                    ZStack {
                        ForEach(gameState.circles) { circle in
                            Image(circle.color.vegetableImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: getVegetableSize(circle.color))
                                .shadow(color: .black.opacity(0.3), radius: 5)
                                .position(
                                    x: min(max(circle.position.x, getVegetableSize(circle.color)/2), screenWidth - getVegetableSize(circle.color)/2),
                                    y: circle.position.y
                                )
                                .opacity(circle.opacity)
                                .scaleEffect(circle.scale)
                                .onTapGesture {
                                    if !gameState.isPaused && !gameState.isGameOver {
                                        handleCircleCollection(circle)
                                    }
                                }
                        }
                        
                        // Shockwave effect
                        if showShockwave {
                            Circle()
                                .stroke(Color.red, lineWidth: 2)
                                .scaleEffect(showShockwave ? 3 : 0)
                                .opacity(showShockwave ? 0 : 1)
                                .animation(.easeOut(duration: 0.3), value: showShockwave)
                                .position(shockwavePosition)
                        }
                        
                        // Game Over overlay
                        if gameState.isGameOver {
                            Color.black.opacity(0.7)
                                .ignoresSafeArea()
                            
                            GameOverView(gameState: gameState)
                                .frame(width: min(geometry.size.width - 40, 300))
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        .edgesIgnoringSafeArea(.bottom) // Only ignore bottom safe area
        .onAppear {
            startFallingAnimation()
            startSpawning(screenWidth: UIScreen.main.bounds.width)
            
            // Debug: Verify background images
            for i in 1...7 {
                let imageName = "gameplay_background\(i)"
                if UIImage(named: imageName) != nil {
                    print("✓ Found image: \(imageName)")
                } else {
                    print("⚠️ Missing image: \(imageName)")
                }
            }
        }
        .onDisappear {
            stopFallingAnimation()
            stopSpawning()
        }
        .onChange(of: gameState.isPaused) { oldValue, newValue in
            if newValue {
                stopFallingAnimation()
                stopSpawning()
            } else {
                startFallingAnimation()
                startSpawning(screenWidth: UIScreen.main.bounds.width)
            }
        }
        .onChange(of: gameState.showLifeLossEffect) { _, newValue in
            if newValue {
                addScreenShakeAnimation()
            }
        }
        .onChange(of: gameState.isLevelComplete) { _, isComplete in
            if isComplete {
                stopFallingAnimation()
                stopSpawning()
            }
        }
        .onChange(of: gameState.isGameOver) { _, isGameOver in
            if isGameOver {
                stopFallingAnimation()
                stopSpawning()
            }
        }
        .onChange(of: gameState.level) { _, _ in
            // Restart animations when level changes
            stopFallingAnimation()
            stopSpawning()
            startFallingAnimation()
            startSpawning(screenWidth: UIScreen.main.bounds.width)
        }
    }
    
    private func addScreenShakeAnimation() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
        
        withAnimation(.easeInOut(duration: 0.1).repeatCount(5)) {
            gameState.screenShakeOffset = CGSize(width: 15, height: 0)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: 0.1)) {
                gameState.screenShakeOffset = .zero
            }
        }
    }
    
    private func showMissEffects(at position: CGPoint) {
        // Set the position and trigger animations
        missedVegetablePosition = position
        
        // Reset states first
        showMissEffect = false
        showShockwave = false
        
        // Trigger animations after a brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeOut(duration: 0.5)) {
                showMissEffect = true
                showShockwave = true
            }
            
            // Haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
            impactFeedback.impactOccurred()
            
            // Reset animations after they complete
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeOut(duration: 0.3)) {
                    showMissEffect = false
                    showShockwave = false
                }
            }
        }
    }
    
    private func startFallingAnimation() {
        guard !gameState.isPaused && !gameState.isGameOver && !gameState.isLevelComplete else { return }
        
        fallTimer?.invalidate()
        
        fallTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { [weak gameState] timer in
            guard let gameState = gameState else { return }
            
            DispatchQueue.main.async {
                var updatedCircles: [GameCircle] = []
                var hasBomb = false
                
                for circle in gameState.circles {
                    if circle.opacity < 1.0 {
                        updatedCircles.append(circle)
                        continue
                    }
                    
                    var updatedCircle = circle
                    let newY = updatedCircle.position.y + gameState.currentSpeed
                    updatedCircle.position.y = newY
                    
                    if newY > UIScreen.main.bounds.height {
                        if circle.color != .bomb {
                            // Show miss effect when vegetable is lost
                            showMissEffects(at: circle.position)
                            gameState.missVegetable() // This will handle the life loss logic
                        }
                        continue
                    }
                    
                    updatedCircles.append(updatedCircle)
                    
                    if circle.color == .bomb {
                        hasBomb = true
                    }
                }
                
                // Make sure bomb tick sound plays as long as there's at least one bomb
                // and stops when there are no bombs
                if !hasBomb {
                    SoundManager.shared.stopSound(Constants.Sounds.bombTick)
                } else if !SoundManager.shared.isPlaying(Constants.Sounds.bombTick) {
                    SoundManager.shared.playSound(Constants.Sounds.bombTick, loop: true)
                }
                
                gameState.circles = updatedCircles
            }
        }
    }
    
    private func handleCircleCollection(_ circle: GameCircle) {
        if circle.color == .bomb {
            handleBombCollection(circle)
            return
        }
        
        // Play swipe sound for collecting vegetables
        SoundManager.shared.playSound(Constants.Sounds.swipe)
        
        // Use the gameState method for adding score instead of direct access
        gameState.addScore(for: circle.color)
        
        withAnimation(.easeOut(duration: 0.3)) {
            if let index = gameState.circles.firstIndex(where: { $0.id == circle.id }) {
                var collectedCircle = gameState.circles[index]
                collectedCircle.scale = 1.5
                collectedCircle.opacity = 0
                gameState.circles[index] = collectedCircle
                
                addCollectionEffects(at: circle.position, color: circle.color)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    gameState.circles.removeAll(where: { $0.id == circle.id })
                }
            }
        }
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    private func handleBombCollection(_ circle: GameCircle) {
        // Stop the bomb tick sound
        SoundManager.shared.stopSound(Constants.Sounds.bombTick)
        
        // Play explosion sound
        SoundManager.shared.playSound(Constants.Sounds.explosion)
        
        // Use gameState method to decrease score for bomb hit
        // Instead of directly modifying the score property
        gameState.addScore(for: .bomb)
        
        // Trigger screen shake
        addScreenShakeAnimation()
        
        // Trigger red flash
        withAnimation(.easeInOut(duration: 0.2)) {
            showBombFlash = true
        }
        
        // Reset flash after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation {
                showBombFlash = false
            }
        }
        
        // Set shockwave position and trigger animation
        shockwavePosition = circle.position
        
        // Create explosion effect
        withAnimation(.easeOut(duration: 0.3)) {
            if let index = gameState.circles.firstIndex(where: { $0.id == circle.id }) {
                var explodingBomb = gameState.circles[index]
                explodingBomb.scale = 2.0
                explodingBomb.opacity = 0
                gameState.circles[index] = explodingBomb
                
                // Show shockwave effect
                showShockwave = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showShockwave = false
                }
            }
        }
        
        // Call lifeManager's loseLife method instead of directly modifying remainingLives
        let isGameOver = gameState.lifeManager.loseLife()
        
        // Check for game over
        if isGameOver {
            gameState.isGameOver = true
            SoundManager.shared.playSound(Constants.Sounds.levelFail)
        }
        
        // Remove the bomb after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            gameState.circles.removeAll { $0.id == circle.id }
        }
    }
    
    private func addCollectionEffects(at position: CGPoint, color: CircleColor) {
        withAnimation(.easeOut(duration: 0.3)) {
            let sparkleCount = 5
            for i in 0..<sparkleCount {
                let angle = (Double(i) / Double(sparkleCount)) * 2 * .pi
                let radius: CGFloat = 30
                let sparklePosition = CGPoint(
                    x: position.x + cos(angle) * radius,
                    y: position.y + sin(angle) * radius
                )
                
                var sparkle = GameCircle(
                    color: color,
                    position: sparklePosition,
                    scale: 0.3,
                    opacity: 0.6
                )
                
                withAnimation(.easeOut(duration: 0.2)) {
                    sparkle.scale = 0
                    sparkle.opacity = 0
                    gameState.circles.append(sparkle)
                }
            }
        }
    }
    
    private func addExplosionEffect(at position: CGPoint) {
        for _ in 0...5 {
            var particle = GameCircle(
                color: .bomb,
                position: position,
                scale: 0.5,
                opacity: 0.8
            )
            
            withAnimation(.easeOut(duration: 0.3)) {
                particle.scale = 0
                particle.opacity = 0
                gameState.circles.append(particle)
            }
        }
    }
    
    private func stopFallingAnimation() {
        fallTimer?.invalidate()
        fallTimer = nil
        // Stop bomb tick sound when game is paused or stopped
        SoundManager.shared.stopSound(Constants.Sounds.bombTick)
    }
    
    private func startSpawning(screenWidth: CGFloat) {
        // Clear any existing timer
        spawnTimer?.invalidate()
        spawnTimer = nil
        
        guard !gameState.isPaused && !gameState.isGameOver && !gameState.isLevelComplete else { return }
        
        // Adjust spawn interval based on level - make items spawn faster in higher levels
        // But not too fast to overwhelm the player
        let baseInterval: Double
        if gameState.level <= 3 {
            baseInterval = max(1.3 - (Double(gameState.level) * 0.05), 0.8)
        } else if gameState.level <= 7 {
            baseInterval = max(1.1 - (Double(gameState.level - 3) * 0.05), 0.7)
        } else {
            baseInterval = max(0.9 - (Double(gameState.level - 7) * 0.03), 0.6)
        }
        
        // Create new timer
        spawnTimer = Timer.scheduledTimer(withTimeInterval: baseInterval, repeats: true) { _ in
            guard !gameState.isPaused && !gameState.isGameOver && !gameState.isLevelComplete else { return }
            spawnCircle(screenWidth: screenWidth)
        }
        
        // Ensure timer is added to the current run loop
        RunLoop.current.add(spawnTimer!, forMode: .common)
        
        // Spawn first circle immediately
        spawnCircle(screenWidth: screenWidth)
    }
    
    private func stopSpawning() {
        spawnTimer?.invalidate()
        spawnTimer = nil
    }
    
    private func spawnCircle(screenWidth: CGFloat) {
        // Get only vegetables that haven't met their target count
        let incompleteVegetables = gameState.currentLevelVegetables.filter { vegetable in
            vegetable != .bomb && 
            (gameState.vegetableCounts[vegetable] ?? 0) < gameState.targetCount
        }
        
        // Calculate spawn position
        let spawnX = CGFloat.random(in: circleSize/2...screenWidth - circleSize/2)
        let screenHeight = UIScreen.main.bounds.height
        let spawnY: CGFloat
        
        if gameState.level >= 7 {
            spawnY = screenHeight * 0.1
        } else {
            let vegetableMinY = screenHeight * 0.1
            let vegetableMaxY = screenHeight * (gameState.level >= 5 ? 0.3 : 0.4)
            spawnY = CGFloat.random(in: vegetableMinY...vegetableMaxY)
        }
        
        // Reduced bomb spawn chance and made it more predictable
        gameState.spawnCounter += 1
        let minVegetablesBeforeBomb = 5  // Minimum vegetables before any bomb can spawn
        
        // Simple bomb spawn threshold based on level
        let bombSpawnThreshold: Int
        if gameState.level <= 3 {
            bombSpawnThreshold = 12
        } else if gameState.level <= 7 {
            bombSpawnThreshold = 10
        } else {
            bombSpawnThreshold = 8
        }
        
        // Simple condition: Spawn bomb when counter exceeds threshold
        let shouldSpawnBomb = gameState.spawnCounter >= bombSpawnThreshold
        
        let spawnPosition = CGPoint(x: spawnX, y: spawnY)
        
        // Get maximum allowed bombs based on level - this is the core requirement
        let maxAllowedBombs: Int
        if gameState.level <= 5 {
            maxAllowedBombs = 2
        } else if gameState.level <= 10 {
            maxAllowedBombs = 3
        } else {
            maxAllowedBombs = 4
        }
        
        // Count current bombs on screen
        let currentBombCount = gameState.circles.filter { $0.color == .bomb }.count
        
        // Create and spawn the circle
        let newCircle: GameCircle
        if shouldSpawnBomb && currentBombCount < maxAllowedBombs {
            // Always reset counter when spawning a bomb
            gameState.spawnCounter = 0
            SoundManager.shared.playSound(Constants.Sounds.bombTick)
            newCircle = GameCircle(color: .bomb, position: spawnPosition)
        } else if !incompleteVegetables.isEmpty {
            // Only spawn from incomplete vegetables
            newCircle = GameCircle(
                color: incompleteVegetables.randomElement() ?? incompleteVegetables[0],
                position: spawnPosition
            )
        } else {
            return // Don't spawn if no valid vegetables to spawn
        }
        
        // Add fade-in animation
        var animatedCircle = newCircle
        animatedCircle.opacity = 0
        withAnimation(.easeIn(duration: 0.2)) {
            animatedCircle.opacity = 1
        }
        gameState.circles.append(animatedCircle)
    }
    
    // Update pause handling
    private func handlePause() {
        if gameState.isPaused {
            stopFallingAnimation()
            stopSpawning()
            SoundManager.shared.stopBackgroundMusic()
        } else {
            startFallingAnimation()
            startSpawning(screenWidth: UIScreen.main.bounds.width)
            SoundManager.shared.playBackgroundMusic("game_play")
        }
    }
}

// Add particle effect modifier
struct ParticleEffect: ViewModifier {
    let angle: Double
    let isActive: Bool
    
    func body(content: Content) -> some View {
        content
            .offset(x: isActive ? cos(angle * .pi / 180) * 50 : 0,
                   y: isActive ? sin(angle * .pi / 180) * 50 : 0)
            .opacity(isActive ? 0 : 1)
            .animation(.easeOut(duration: 0.5), value: isActive)
    }
} 
