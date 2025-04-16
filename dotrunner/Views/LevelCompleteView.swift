import SwiftUI

struct LevelCompleteView: View {
    @ObservedObject var gameState: GameState
    @Environment(\.dismiss) private var dismiss
    @AppStorage("isMusicEnabled") private var isMusicEnabled = true
    
    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            // Content
            VStack(spacing: 25) {
                // Level Complete Text
                Text("Level \(gameState.level) Complete!")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                    .glow(color: .green, radius: 10)
                
                // Score Display
                VStack(spacing: 15) {
                    Text("Level Score: \(gameState.score)")
                        .font(.title2.bold())
                        .foregroundColor(.yellow)
                        .glow(color: .orange, radius: 5)
                    
                    Text("High Score: \(gameState.highScore)")
                        .font(.title3.bold())
                        .foregroundColor(.white)
                        .glow(color: .blue, radius: 5)
                    
                    // Bonus Life Message (if not at max lives)
                    if gameState.remainingLives < 5 {
                        Text("🎁 Bonus Life Awarded!")
                            .font(.title3.bold())
                            .foregroundColor(.green)
                            .glow(color: .green, radius: 8)
                            .padding(.top, 5)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding(.vertical, 20)
                
                // Buttons
                VStack(spacing: 15) {
                    Button {
                        withAnimation {
                            gameState.startNextLevel()
                            if isMusicEnabled {
                                SoundManager.shared.playBackgroundMusic("game_play")
                            }
                        }
                    } label: {
                        Text("Next Level")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                            .frame(width: 200, height: 50)
                            .background(
                                LinearGradient(colors: [.green.opacity(0.8), .green.opacity(0.6)],
                                             startPoint: .leading,
                                             endPoint: .trailing)
                            )
                            .cornerRadius(25)
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
                            )
                            .shadow(color: .green.opacity(0.5), radius: 5)
                    }
                    
                    Button {
                        withAnimation {
                            gameState.goToHome()
                        }
                    } label: {
                        Text("Home")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                            .frame(width: 200, height: 50)
                            .background(
                                LinearGradient(colors: [.blue.opacity(0.8), .blue.opacity(0.6)],
                                             startPoint: .leading,
                                             endPoint: .trailing)
                            )
                            .cornerRadius(25)
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
                            )
                            .shadow(color: .blue.opacity(0.5), radius: 5)
                    }
                }
            }
            .padding()
        }
    }
} 