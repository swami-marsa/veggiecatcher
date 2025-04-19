import SwiftUI

struct LevelCompleteView: View {
    @ObservedObject var gameState: GameState
    @Environment(\.dismiss) private var dismiss
    @AppStorage("isMusicEnabled") private var isMusicEnabled = true
    private let deviceManager = DeviceManager.shared
    
    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            // Content
            VStack(spacing: deviceManager.isIpad ? 40 : 25) {
                // Level Complete Text
                Text("Level \(gameState.level) Complete!")
                    .font(Font.system(size: deviceManager.levelCompleteTitleSize(), weight: .bold))
                    .foregroundColor(.white)
                    .addGlow(color: .green, radius: deviceManager.isIpad ? 15 : 10)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, deviceManager.isIpad ? 30 : 15)
                
                // Score Display
                VStack(spacing: deviceManager.isIpad ? 25 : 15) {
                    Text("Level Score: \(gameState.score)")
                        .font(.system(size: deviceManager.levelCompleteScoreSize(), weight: .bold))
                        .foregroundColor(.yellow)
                        .addGlow(color: .orange, radius: deviceManager.isIpad ? 8 : 5)
                    
                    Text("High Score: \(gameState.highScore)")
                        .font(.system(size: deviceManager.levelCompleteHighScoreSize(), weight: .bold))
                        .foregroundColor(.white)
                        .addGlow(color: .blue, radius: deviceManager.isIpad ? 8 : 5)
                    
                    // Bonus Life Message (if not at max lives)
                    if gameState.remainingLives < 5 {
                        Text("🎁 Bonus Life Awarded!")
                            .font(.system(size: deviceManager.levelCompleteBonusSize(), weight: .bold))
                            .foregroundColor(.green)
                            .addGlow(color: .green, radius: deviceManager.isIpad ? 12 : 8)
                            .padding(.top, deviceManager.isIpad ? 10 : 5)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding(.vertical, deviceManager.isIpad ? 30 : 20)
                
                // Buttons
                VStack(spacing: deviceManager.isIpad ? 25 : 15) {
                    Button {
                        withAnimation {
                            gameState.startNextLevel()
                            if isMusicEnabled {
                                SoundManager.shared.playBackgroundMusic("game_play")
                            }
                        }
                    } label: {
                        Text("Next Level")
                            .font(.system(size: deviceManager.isIpad ? 28 : 20, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: deviceManager.levelCompleteButtonWidth(), height: deviceManager.isIpad ? 80 : 50)
                            .background(
                                LinearGradient(colors: [.green.opacity(0.8), .green.opacity(0.6)],
                                             startPoint: .leading,
                                             endPoint: .trailing)
                            )
                            .cornerRadius(deviceManager.isIpad ? 40 : 25)
                            .overlay(
                                RoundedRectangle(cornerRadius: deviceManager.isIpad ? 40 : 25)
                                    .stroke(Color.white.opacity(0.5), lineWidth: deviceManager.isIpad ? 2 : 1)
                            )
                            .shadow(color: .green.opacity(0.5), radius: deviceManager.isIpad ? 8 : 5)
                    }
                    
                    Button {
                        withAnimation {
                            // Make sure level is properly saved before going home
                            gameState.scoreManager.saveLastPlayedLevel(gameState.level)
                            gameState.scoreManager.saveContinuationScore()
                            
                            // Force UserDefaults to synchronize
                            UserDefaults.standard.synchronize()
                            
                            // Now go to home
                            gameState.goToHome()
                        }
                    } label: {
                        Text("Home")
                            .font(.system(size: deviceManager.isIpad ? 28 : 20, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: deviceManager.levelCompleteButtonWidth(), height: deviceManager.isIpad ? 80 : 50)
                            .background(
                                LinearGradient(colors: [.blue.opacity(0.8), .blue.opacity(0.6)],
                                             startPoint: .leading,
                                             endPoint: .trailing)
                            )
                            .cornerRadius(deviceManager.isIpad ? 40 : 25)
                            .overlay(
                                RoundedRectangle(cornerRadius: deviceManager.isIpad ? 40 : 25)
                                    .stroke(Color.white.opacity(0.5), lineWidth: deviceManager.isIpad ? 2 : 1)
                            )
                            .shadow(color: .blue.opacity(0.5), radius: deviceManager.isIpad ? 8 : 5)
                    }
                }
            }
            .padding(deviceManager.isIpad ? 40 : 20)
            .background(
                RoundedRectangle(cornerRadius: deviceManager.isIpad ? 30 : 20)
                    .fill(Color.black.opacity(0.7))
                    .overlay(
                        RoundedRectangle(cornerRadius: deviceManager.isIpad ? 30 : 20)
                            .stroke(
                                LinearGradient(
                                    colors: [.green.opacity(0.7), .blue.opacity(0.5)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: deviceManager.isIpad ? 3 : 2
                            )
                    )
                    .shadow(color: .green.opacity(0.3), radius: deviceManager.isIpad ? 20 : 10)
            )
            .frame(width: min(UIScreen.main.bounds.width - (deviceManager.isIpad ? 100 : 40), deviceManager.isIpad ? 700 : 500))
        }
    }
} 