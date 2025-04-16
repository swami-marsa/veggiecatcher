import SwiftUI

struct PauseMenuView: View {
    @ObservedObject var gameState: GameState
    @AppStorage("isMusicEnabled") private var isMusicEnabled = true
    
    var body: some View {
        ZStack {
            // Blurred background
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            // Main content
            VStack(spacing: 30) {
                // Pause icon and title
                VStack(spacing: 15) {
                    Image(systemName: "pause.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                        .glow(color: .blue, radius: 10)
                    
                    Text("Game Paused")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .glow(color: .blue, radius: 8)
                }
                
                // Current score display
                VStack(spacing: 8) {
                    Text("Current Score")
                        .font(.title3)
                        .foregroundColor(.gray)
                    Text("\(gameState.score)")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                        .glow(color: .blue, radius: 8)
                }
                .padding(.vertical, 10)
                
                // Action buttons
                VStack(spacing: 15) {
                    Button(action: {
                        withAnimation {
                            gameState.isPaused = false
                            if isMusicEnabled {
                                SoundManager.shared.playBackgroundMusic("game_play")
                            }
                        }
                    }) {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Resume Game")
                        }
                        .font(.title3.bold())
                        .foregroundColor(.white)
                        .frame(width: 250, height: 50)
                        .background(
                            LinearGradient(
                                colors: [.green.opacity(0.8), .green.opacity(0.6)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(25)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.white.opacity(0.5), lineWidth: 1)
                        )
                        .shadow(color: .green.opacity(0.5), radius: 5)
                    }
                    
                    Button(action: {
                        withAnimation {
                            gameState.goToHome()
                        }
                    }) {
                        HStack {
                            Image(systemName: "house.fill")
                            Text("Main Menu")
                        }
                        .font(.title3.bold())
                        .foregroundColor(.white)
                        .frame(width: 250, height: 50)
                        .background(
                            LinearGradient(
                                colors: [.blue.opacity(0.8), .blue.opacity(0.6)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(25)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.white.opacity(0.5), lineWidth: 1)
                        )
                        .shadow(color: .blue.opacity(0.5), radius: 5)
                    }
                    
                    Button(action: {
                        // Quit the game
                        exit(0)
                    }) {
                        HStack {
                            Image(systemName: "power")
                            Text("Quit Game")
                        }
                        .font(.title3.bold())
                        .foregroundColor(.white)
                        .frame(width: 250, height: 50)
                        .background(
                            LinearGradient(
                                colors: [.red.opacity(0.8), .red.opacity(0.6)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(25)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.white.opacity(0.5), lineWidth: 1)
                        )
                        .shadow(color: .red.opacity(0.5), radius: 5)
                    }
                }
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(
                        LinearGradient(
                            colors: [Color.black.opacity(0.8), Color.blue.opacity(0.2)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
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

struct MenuButtonStyle: ButtonStyle {
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