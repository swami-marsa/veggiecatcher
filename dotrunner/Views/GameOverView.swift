import SwiftUI

struct GameOverView: View {
    @ObservedObject var gameState: GameState
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Game Over!")
                .font(Font.system(size: 32, weight: .bold))
                .foregroundColor(.white)
                .padding()
                .addGlow(color: .red, radius: 10)
            
            Text("Score: \(gameState.score)")
                .font(.title2)
                .foregroundColor(.white)
                .padding(.bottom, 10)
            
            Button("Play Again") {
                gameState.resetGame()
            }
            .buttonStyle(GameOverButtonStyle(color: .blue))
            
            Button("Main Menu") {
                gameState.goToHome()
            }
            .buttonStyle(GameOverButtonStyle(color: .gray))
        }
        .padding(24)
    }
}

// Button style defined specifically for this view
struct GameOverButtonStyle: ButtonStyle {
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title2)
            .foregroundColor(.white)
            .padding(.horizontal, 40)
            .padding(.vertical, 12)
            .background(color.opacity(configuration.isPressed ? 0.7 : 1))
            .cornerRadius(10)
    }
} 