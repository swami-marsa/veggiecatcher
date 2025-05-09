import SwiftUI

struct GameOverView: View {
    @ObservedObject var gameState: GameState
    @State private var showRewardedAdView = false
    private let deviceManager = DeviceManager.shared
    
    var body: some View {
        VStack(spacing: deviceManager.isIpad ? 30 : 20) {
            Text("Game Over!")
                .font(Font.system(size: deviceManager.gameOverTitleSize(), weight: .bold))
                .foregroundColor(.white)
                .padding()
                .addGlow(color: .red, radius: deviceManager.isIpad ? 15 : 10)
            
            Text("Score: \(gameState.score)")
                .font(.system(size: deviceManager.gameOverScoreSize(), weight: .bold))
                .foregroundColor(.white)
                .padding(.bottom, deviceManager.isIpad ? 20 : 10)
            
            if AdIntegration.isRewardedAdAvailable() && !showRewardedAdView {
                Button("Extra Life") {
                    showRewardedAdView = true
                }
                .buttonStyle(GameOverButtonStyle(color: .green, deviceManager: deviceManager))
            }
            
            Button("Play Again") {
                gameState.resetGame()
            }
            .buttonStyle(GameOverButtonStyle(color: .blue, deviceManager: deviceManager))
            
            Button("Main Menu") {
                gameState.goToHome()
            }
            .buttonStyle(GameOverButtonStyle(color: .gray, deviceManager: deviceManager))
        }
        .padding(deviceManager.isIpad ? 40 : 24)
        .frame(width: deviceManager.gameOverWidth())
        .background(
            RoundedRectangle(cornerRadius: deviceManager.isIpad ? 30 : 20)
                .fill(Color.black.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: deviceManager.isIpad ? 30 : 20)
                        .stroke(
                            LinearGradient(
                                colors: [.red.opacity(0.7), .orange.opacity(0.5)],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: deviceManager.isIpad ? 3 : 2
                        )
                )
                .shadow(color: .red.opacity(0.3), radius: deviceManager.isIpad ? 20 : 10)
        )
        .overlay(
            ZStack {
                if showRewardedAdView {
                    Color.black.opacity(0.6)
                        .edgesIgnoringSafeArea(.all)
                    
                    RewardedAdView(
                        onRewardEarned: {
                            showRewardedAdView = false
                            
                            // First refill lives
                            gameState.refillAllLives()
                            
                            // Then explicitly tell the game to continue (this is the crucial part)
                            withAnimation {
                                // This dismiss call is critical to remove the game over overlay
                                gameState.isGameOver = false
                            }
                            
                            // Restart gameplay music
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                SoundManager.shared.playBackgroundMusic("game_play")
                            }
                        },
                        onDecline: {
                            showRewardedAdView = false
                        }
                    )
                    .transition(.scale)
                }
            }
            .animation(.easeInOut, value: showRewardedAdView)
        )
    }
}

// Button style defined specifically for this view
struct GameOverButtonStyle: ButtonStyle {
    let color: Color
    let deviceManager: DeviceManager
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: deviceManager.isIpad ? 28 : 20, weight: .bold))
            .foregroundColor(.white)
            .padding(.horizontal, deviceManager.isIpad ? 60 : 40)
            .padding(.vertical, deviceManager.isIpad ? 16 : 12)
            .frame(width: deviceManager.isIpad ? 300 : 200)
            .background(
                RoundedRectangle(cornerRadius: deviceManager.isIpad ? 20 : 10)
                    .fill(color.opacity(configuration.isPressed ? 0.7 : 1))
                    .shadow(color: color.opacity(0.5), radius: deviceManager.isIpad ? 8 : 5)
            )
    }
} 