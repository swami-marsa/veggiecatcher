import SwiftUI

struct GameView: View {
    @ObservedObject var gameState: GameState
    @AppStorage("isMusicEnabled") private var isMusicEnabled = true
    @State private var showQuitConfirmation = false
    
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
                            HStack(spacing: 4) { // Increased spacing between hearts
                                ForEach(0..<5) { index in
                                    Image(systemName: index < gameState.remainingLives ? "heart.fill" : "heart")
                                        .foregroundColor(index < gameState.remainingLives ? .red : .gray)
                                        .font(.system(size: 22, weight: .bold)) // Increased size and bold
                                        .shadow(color: .black, radius: 1, x: 1, y: 1) // Sharp shadow
                                        .shadow(color: index < gameState.remainingLives ? .red : .clear, radius: 4, x: 0, y: 0) // Outer glow
                                        .overlay( // Inner highlight
                                            Image(systemName: index < gameState.remainingLives ? "heart.fill" : "heart")
                                                .foregroundColor(.white)
                                                .font(.system(size: 22, weight: .bold))
                                                .opacity(0.3)
                                                .offset(x: -1, y: -1)
                                        )
                                }
                            }
                            .padding(.leading, 6)
                            
                            Spacer()
                            
                            // Level and pause
                            HStack(spacing: 8) {
                                // Enhanced Level display
                                Text("L\(gameState.level)")
                                    .font(.system(size: 24, weight: .heavy)) // Larger and heavier
                                    .foregroundColor(.white)
                                    .shadow(color: .black, radius: 1, x: 1, y: 1) // Sharp shadow
                                    .overlay( // Text border
                                        Text("L\(gameState.level)")
                                            .font(.system(size: 24, weight: .heavy))
                                            .foregroundColor(.green)
                                            .opacity(0.7)
                                    )
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
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
                                        .font(.system(size: 32)) // Slightly larger
                                        .foregroundColor(.white)
                                        .shadow(color: .black, radius: 2)
                                        .shadow(color: .blue, radius: 4)
                                }
                            }
                            .padding(.trailing, 6)
                        }
                        
                        // Progress bars
                        progressBars(geometry: geometry)
                        
                        // Score display
                        HStack {
                            Spacer()
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                    .font(.system(size: 16))
                                    .glow(color: .orange, radius: 8)
                                
                                Text("\(gameState.score)")
                                    .foregroundColor(.white)
                                    .font(.system(size: 16, weight: .bold))
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        // Enhanced 3D colorful background with proper margins
                        RoundedRectangle(cornerRadius: 15)
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
                                RoundedRectangle(cornerRadius: 15)
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
                                RoundedRectangle(cornerRadius: 15)
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
                                        lineWidth: 2
                                    )
                            )
                            .shadow(color: .blue.opacity(0.5), radius: 5, x: 0, y: 2)
                            .shadow(color: .purple.opacity(0.3), radius: 10, x: 0, y: 4)
                    )
                    .frame(width: min(geometry.size.width - 32, 600)) // Ensure proper width with margins
                    
                    Spacer()
                }
                .offset(y: 5)
                
                // Pause Menu with Quit Confirmation
                if gameState.isPaused {
                    if showQuitConfirmation {
                        ZStack {
                            Color.black.opacity(0.7)
                                .ignoresSafeArea()
                            
                            VStack(spacing: 25) {
                                Text("Paused")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.white)
                                    .glow(color: .blue, radius: 10)
                                
                                VStack(spacing: 15) {
                                    Button(action: {
                                        withAnimation {
                                            gameState.isPaused = false
                                            showQuitConfirmation = false
                                            SoundManager.shared.playBackgroundMusic("game_play")
                                        }
                                    }) {
                                        Text("Resume Game")
                                            .buttonStyle(width: 200, color: .green)
                                    }
                                    
                                    Button(action: {
                                        withAnimation {
                                            gameState.goToHome()
                                            showQuitConfirmation = false
                                        }
                                    }) {
                                        Text("Main Menu")
                                            .buttonStyle(width: 200, color: .blue)
                                    }
                                    
                                    Button(action: {
                                        exit(0)
                                    }) {
                                        Text("Quit Game")
                                            .buttonStyle(width: 200, color: .red)
                                    }
                                }
                            }
                            .padding(32)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(Color.black.opacity(0.8))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 25)
                                            .stroke(
                                                LinearGradient(
                                                    colors: [.blue.opacity(0.6), .purple.opacity(0.6)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 2
                                            )
                                    )
                            )
                            .shadow(color: .blue.opacity(0.3), radius: 20)
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
        let barWidth = (geometry.size.width - 48) / 4 // Adjusted spacing
        
        return HStack(spacing: 6) { // Reduced spacing between bars
            // Filter out bomb from progress bars
            ForEach(gameState.currentLevelVegetables.filter { $0 != .bomb }, id: \.self) { vegetable in
                VStack(spacing: 2) {
                    // Vegetable icon
                    Image(vegetable.vegetableImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                    
                    // Progress bar
                    ProgressBar(
                        progress: CGFloat(gameState.vegetableCounts[vegetable] ?? 0) / CGFloat(gameState.targetCount),
                        colors: vegetable.gradientColors,
                        isComplete: (gameState.vegetableCounts[vegetable] ?? 0) >= gameState.targetCount,
                        width: barWidth - 24
                    )
                }
                .frame(width: barWidth)
                .padding(.vertical, 4)
                .background(Color.black.opacity(0.3))
                .cornerRadius(8)
            }
        }
    }
}

struct ProgressBar: View {
    let progress: CGFloat
    let colors: [Color]
    let isComplete: Bool
    let width: CGFloat
    
    var body: some View {
        HStack(spacing: 4) {
            Capsule()
                .fill(Color.white.opacity(0.2))
                .overlay(
                    Capsule()
                        .fill(LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing))
                        .frame(width: width * min(progress, 1.0))
                )
                .frame(width: width, height: 6)
            
            if isComplete {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.green)
            }
        }
        .animation(.spring(duration: 0.3), value: progress)
    }
}

// Helper extension for button styling
extension Text {
    func buttonStyle(width: CGFloat, color: Color) -> some View {
        self
            .font(.title3.bold())
            .foregroundColor(.white)
            .frame(width: width, height: 50)
            .background(
                LinearGradient(
                    colors: [color.opacity(0.8), color.opacity(0.6)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(25)
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
            )
            .shadow(color: color.opacity(0.5), radius: 5)
    }
} 