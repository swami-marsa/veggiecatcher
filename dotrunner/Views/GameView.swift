import SwiftUI

struct GameView: View {
    @ObservedObject var gameState: GameState
    @AppStorage("isMusicEnabled") private var isMusicEnabled = true
    @State private var showQuitConfirmation = false
    private let deviceManager = DeviceManager.shared
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Game Area
                CircleGameArea(gameState: gameState)
                
                // Top UI Layer
                VStack(spacing: 0) {
                    // Unified status bar with enhanced 3D effect
                    VStack(spacing: 4) {
                        // Top row: Lives and Level
                        HStack(spacing: 12) {
                            // Lives with enhanced glow effect
                            HStack(spacing: deviceManager.isIpad ? 8 : 4) { // Increased spacing for iPad
                                ForEach(0..<5) { index in
                                    Image(systemName: index < gameState.remainingLives ? "heart.fill" : "heart")
                                        .foregroundColor(index < gameState.remainingLives ? .red : .gray)
                                        .font(.system(size: deviceManager.heartIconSize(), weight: .bold))
                                        .shadow(color: .black, radius: 1, x: 1, y: 1) // Sharp shadow
                                        .shadow(color: index < gameState.remainingLives ? .red : .clear, radius: 4, x: 0, y: 0) // Outer glow
                                        .overlay( // Inner highlight
                                            Image(systemName: index < gameState.remainingLives ? "heart.fill" : "heart")
                                                .foregroundColor(.white)
                                                .font(.system(size: deviceManager.heartIconSize(), weight: .bold))
                                                .opacity(0.3)
                                                .offset(x: -1, y: -1)
                                        )
                                }
                            }
                            .padding(.leading, deviceManager.isIpad ? 12 : 6)
                            
                            Spacer()
                            
                            // Level and pause
                            HStack(spacing: deviceManager.isIpad ? 16 : 8) {
                                // Enhanced Level display
                                Text("L\(gameState.level)")
                                    .font(.system(size: deviceManager.levelTextSize(), weight: .heavy))
                                    .foregroundColor(.white)
                                    .shadow(color: .black, radius: 1, x: 1, y: 1) // Sharp shadow
                                    .overlay( // Text border
                                        Text("L\(gameState.level)")
                                            .font(.system(size: deviceManager.levelTextSize(), weight: .heavy))
                                            .foregroundColor(.green)
                                            .opacity(0.7)
                                    )
                                    .padding(.horizontal, deviceManager.isIpad ? 20 : 12)
                                    .padding(.vertical, deviceManager.isIpad ? 10 : 6)
                                    .background(
                                        RoundedRectangle(cornerRadius: deviceManager.isIpad ? 20 : 12)
                                            .fill(
                                                LinearGradient(
                                                    colors: [
                                                        Color.green.opacity(0.7),
                                                        Color.green.opacity(0.3)
                                                    ],
                                                    startPoint: .top,
                                                    endPoint: .bottom
                                                )
                                            )
                                            .shadow(color: .black, radius: 2)
                                    )
                                
                                Button(action: {
                                    withAnimation {
                                        gameState.isPaused.toggle()
                                        if gameState.isPaused {
                                            SoundManager.shared.stopBackgroundMusic()
                                            showQuitConfirmation = true
                                        } else {
                                            SoundManager.shared.playBackgroundMusic("game_play")
                                        }
                                    }
                                }) {
                                    Image(systemName: gameState.isPaused ? "play.circle.fill" : "pause.circle.fill")
                                        .font(.system(size: deviceManager.pauseIconSize())) 
                                        .foregroundColor(.white)
                                        .shadow(color: .black, radius: 2)
                                        .shadow(color: .blue, radius: 4)
                                        .frame(width: deviceManager.pauseButtonSize(), height: deviceManager.pauseButtonSize())
                                }
                            }
                            .padding(.trailing, deviceManager.isIpad ? 12 : 6)
                        }
                        
                        // Progress bars
                        progressBars(geometry: geometry)
                        
                        // Score display
                        HStack {
                            Spacer()
                            HStack(spacing: deviceManager.isIpad ? 8 : 4) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                    .font(.system(size: deviceManager.scoreIconSize()))
                                    .glow(color: .orange, radius: deviceManager.isIpad ? 16 : 8)
                                
                                Text("\(gameState.score)")
                                    .foregroundColor(.white)
                                    .font(.system(size: deviceManager.scoreTextSize(), weight: .bold))
                            }
                        }
                    }
                    .padding(.horizontal, deviceManager.isIpad ? 20 : 12)
                    .padding(.vertical, deviceManager.isIpad ? 16 : 8)
                    .background(
                        // Enhanced 3D colorful background with proper margins
                        RoundedRectangle(cornerRadius: deviceManager.isIpad ? 25 : 15)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "2E3192").opacity(0.9),
                                        Color(hex: "1BFFFF").opacity(0.4)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                // Metallic effect
                                RoundedRectangle(cornerRadius: deviceManager.isIpad ? 25 : 15)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                .white.opacity(0.3),
                                                .clear,
                                                .white.opacity(0.1)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                            .overlay(
                                // Rainbow border
                                RoundedRectangle(cornerRadius: deviceManager.isIpad ? 25 : 15)
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                .purple.opacity(0.8),
                                                .blue.opacity(0.8),
                                                .cyan.opacity(0.8),
                                                .green.opacity(0.8)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: deviceManager.isIpad ? 3 : 2
                                    )
                            )
                            .shadow(color: .blue.opacity(0.5), radius: deviceManager.isIpad ? 8 : 5, x: 0, y: deviceManager.isIpad ? 3 : 2)
                            .shadow(color: .purple.opacity(0.3), radius: deviceManager.isIpad ? 16 : 10, x: 0, y: deviceManager.isIpad ? 6 : 4)
                    )
                    .frame(width: min(geometry.size.width - (deviceManager.isIpad ? 48 : 32), deviceManager.isIpad ? 800 : 600))
                    
                    Spacer()
                }
                .offset(y: 5)
                
                // Pause Menu with Quit Confirmation
                if gameState.isPaused {
                    if showQuitConfirmation {
                        ZStack {
                            Color.black.opacity(0.7)
                                .ignoresSafeArea()
                            
                            VStack(spacing: deviceManager.isIpad ? 40 : 25) {
                                Text("Paused")
                                    .font(.system(size: deviceManager.isIpad ? 56 : 32, weight: .bold))
                                    .foregroundColor(.white)
                                    .glow(color: .blue, radius: deviceManager.isIpad ? 16 : 10)
                                
                                VStack(spacing: deviceManager.isIpad ? 25 : 15) {
                                    Button(action: {
                                        withAnimation {
                                            gameState.isPaused = false
                                            showQuitConfirmation = false
                                            SoundManager.shared.playBackgroundMusic("game_play")
                                        }
                                    }) {
                                        Text("Resume Game")
                                            .gameButtonStyle(width: deviceManager.isIpad ? 350 : 200, color: .green)
                                    }
                                    
                                    Button(action: {
                                        withAnimation {
                                            gameState.goToHome()
                                            showQuitConfirmation = false
                                        }
                                    }) {
                                        Text("Main Menu")
                                            .gameButtonStyle(width: deviceManager.isIpad ? 350 : 200, color: .blue)
                                    }
                                    
                                    Button(action: {
                                        exit(0)
                                    }) {
                                        Text("Quit Game")
                                            .gameButtonStyle(width: deviceManager.isIpad ? 350 : 200, color: .red)
                                    }
                                }
                            }
                            .padding(deviceManager.isIpad ? 50 : 32)
                            .background(
                                RoundedRectangle(cornerRadius: deviceManager.isIpad ? 40 : 25)
                                    .fill(Color.black.opacity(0.8))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: deviceManager.isIpad ? 40 : 25)
                                            .stroke(
                                                LinearGradient(
                                                    colors: [.blue.opacity(0.6), .purple.opacity(0.6)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: deviceManager.isIpad ? 3 : 2
                                            )
                                    )
                            )
                            .shadow(color: .blue.opacity(0.3), radius: deviceManager.isIpad ? 30 : 20)
                        }
                        .transition(.opacity)
                    }
                }
                
                if gameState.isLevelComplete {
                    LevelCompleteView(gameState: gameState)
                        .transition(.opacity)
                }
            }
        }
        .onAppear {
            if isMusicEnabled {
                SoundManager.shared.playBackgroundMusic("game_play")
            }
        }
    }
    
    private func progressBars(geometry: GeometryProxy) -> some View {
        let barWidth = (geometry.size.width - (deviceManager.isIpad ? 64 : 48)) / 4 // Adjusted spacing
        
        return HStack(spacing: deviceManager.isIpad ? 10 : 6) { // Increased spacing for iPad
            // Filter out bomb from progress bars
            ForEach(gameState.currentLevelVegetables.filter { $0 != .bomb }, id: \.self) { vegetable in
                VStack(spacing: deviceManager.isIpad ? 4 : 2) {
                    // Vegetable icon
                    Image(vegetable.vegetableImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: deviceManager.isIpad ? 36 : 20, height: deviceManager.isIpad ? 36 : 20)
                    
                    // Progress bar
                    ProgressBar(
                        progress: CGFloat(gameState.vegetableCounts[vegetable] ?? 0) / CGFloat(gameState.targetCount),
                        colors: vegetable.gradientColors,
                        isComplete: (gameState.vegetableCounts[vegetable] ?? 0) >= gameState.targetCount,
                        width: barWidth - (deviceManager.isIpad ? 40 : 24),
                        deviceManager: deviceManager
                    )
                }
                .frame(width: barWidth)
                .padding(.vertical, deviceManager.isIpad ? 8 : 4)
                .background(Color.black.opacity(0.3))
                .cornerRadius(deviceManager.isIpad ? 12 : 8)
            }
        }
    }
}

struct ProgressBar: View {
    let progress: CGFloat
    let colors: [Color]
    let isComplete: Bool
    let width: CGFloat
    let deviceManager: DeviceManager
    
    var body: some View {
        HStack(spacing: deviceManager.isIpad ? 8 : 4) {
            Capsule()
                .fill(Color.white.opacity(0.2))
                .overlay(
                    Capsule()
                        .fill(LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing))
                        .frame(width: width * min(progress, 1.0))
                )
                .frame(width: width, height: deviceManager.progressBarHeight())
            
            if isComplete {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: deviceManager.isIpad ? 22 : 12))
                    .foregroundColor(.green)
            }
        }
        .animation(.spring(duration: 0.3), value: progress)
    }
}

// Helper extension for button styling
extension Text {
    func gameButtonStyle(width: CGFloat, color: Color) -> some View {
        let deviceManager = DeviceManager.shared
        
        return self
            .font(.system(size: deviceManager.isIpad ? 28 : 20, weight: .bold))
            .foregroundColor(.white)
            .frame(width: width, height: deviceManager.isIpad ? 80 : 50)
            .background(
                LinearGradient(
                    colors: [color.opacity(0.8), color.opacity(0.6)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(deviceManager.isIpad ? 40 : 25)
            .overlay(
                RoundedRectangle(cornerRadius: deviceManager.isIpad ? 40 : 25)
                    .stroke(Color.white.opacity(0.5), lineWidth: deviceManager.isIpad ? 2 : 1)
            )
            .shadow(color: color.opacity(0.5), radius: deviceManager.isIpad ? 8 : 5)
    }
} 