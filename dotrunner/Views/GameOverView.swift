import SwiftUI

struct GameOverView: View {
    @ObservedObject var gameState: GameState
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Game Over!")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
                .padding()
                .glow(color: .red, radius: 10)
            
            Text("Score: \(gameState.score)")
                .font(.title2)
                .foregroundColor(.white)
                .padding(.bottom, 10)
            
            Button("Play Again") {
                gameState.resetGame()
            }
            .buttonStyle(MenuButtonStyle(color: .blue))
            
            Button("Main Menu") {
                gameState.goToHome()
            }
            .buttonStyle(MenuButtonStyle(color: .gray))
        }
        .padding(24)
    }
} 