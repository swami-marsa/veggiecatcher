import SwiftUI

struct HomeScreen: View {
    @ObservedObject var gameState: GameState
    @AppStorage("isMusicEnabled") private var isMusicEnabled = true
    @AppStorage("isSoundEffectsEnabled") private var isSoundEffectsEnabled = true
    
    var body: some View {
        ZStack {
            // Background image with full resolution
            Image("splash_background")
                .interpolation(.high)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            // Main content
            VStack {
                // Score and Settings Bar - Simplified design
                HStack {
                    // High Score Section - now on the left with its own background
                    if gameState.highScore > 0 {
                        HStack(spacing: 8) {
                            Image(systemName: "trophy.fill")
                                .font(.system(size: 22))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.3), radius: 4, x: 2, y: 2)
                            
                            Text("\(gameState.highScore)")
                                .font(.system(size: 26, weight: .heavy))
                                .minimumScaleFactor(0.5)
                                .lineLimit(1)
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.3), radius: 4, x: 2, y: 2)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .frame(minWidth: 120)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.9, green: 0.5, blue: 0.1),  // Orange gradient
                                            Color(red: 0.8, green: 0.3, blue: 0.0)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(color: .black.opacity(0.3), radius: 8)
                        )
                    }
                    
                    Spacer()
                    
                    // Sound Controls - now with individual circular backgrounds
                    HStack(spacing: 15) {
                        // Music Toggle
                        Button(action: {
                            isMusicEnabled.toggle()
                            SoundManager.shared.setMusicEnabled(isMusicEnabled)
                            if isMusicEnabled {
                                SoundManager.shared.playBackgroundMusic("game_home")
                            }
                        }) {
                            Image(systemName: isMusicEnabled ? "music.note" : "speaker.slash.circle.fill")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 45, height: 45)
                                .background(
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    Color(red: 0.9, green: 0.3, blue: 0.1),
                                                    Color(red: 0.7, green: 0.1, blue: 0.0)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                )
                                .overlay(
                                    Circle()
                                        .stroke(
                                            LinearGradient(
                                                colors: [
                                                    Color.white.opacity(0.6),
                                                    Color.white.opacity(0.2),
                                                    Color.black.opacity(0.2)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 2
                                        )
                                )
                                .shadow(color: .black.opacity(0.3), radius: 5)
                                .scaleEffect(isMusicEnabled ? 1.0 : 0.9)
                        }
                        
                        // Effects Toggle
                        Button(action: {
                            isSoundEffectsEnabled.toggle()
                            if isSoundEffectsEnabled {
                                SoundManager.shared.playSound("swipe")
                            }
                            SoundManager.shared.setEffectsEnabled(isSoundEffectsEnabled)
                        }) {
                            Image(systemName: isSoundEffectsEnabled ? "speaker.wave.3.fill" : "speaker.slash.circle.fill")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 45, height: 45)
                                .background(
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    Color(red: 0.2, green: 0.6, blue: 0.1),
                                                    Color(red: 0.1, green: 0.4, blue: 0.0)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                )
                                .overlay(
                                    Circle()
                                        .stroke(
                                            LinearGradient(
                                                colors: [
                                                    Color.white.opacity(0.6),
                                                    Color.white.opacity(0.2),
                                                    Color.black.opacity(0.2)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 2
                                        )
                                )
                                .shadow(color: .black.opacity(0.3), radius: 5)
                                .scaleEffect(isSoundEffectsEnabled ? 1.0 : 0.9)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                }
                .padding(.horizontal, 20)
                .padding(.top, 250)  // Increased top padding
                
                Spacer()
                
                // Game logo
                Image(uiImage: UIImage(named: "AppIcon") ?? UIImage())
                    .resizable()
                    .interpolation(.high)
                    .antialiased(true)
                    .scaledToFit()
                    .frame(width: 140, height: 140)
                    .cornerRadius(35)
                    .shadow(color: .white.opacity(0.5), radius: 10)
                    .glow(color: .blue, radius: 20)
                
                Spacer()
                
                // Game Buttons
                VStack(spacing: 25) {
                    if gameState.lastPlayedLevel > 1 && !gameState.isGameOver {
                        Button {
                            withAnimation {
                                gameState.continueGame()
                                gameState.isHomeScreen = false
                            }
                        } label: {
                            Text("Continue Level \(gameState.lastPlayedLevel + 1)")
                                .font(.title2.bold())
                                .foregroundColor(.white)
                                .frame(width: 250, height: 50)
                                .background(
                                    LinearGradient(colors: [.blue.opacity(0.8), .blue.opacity(0.6)],
                                                 startPoint: .topLeading,
                                                 endPoint: .bottomTrailing)
                                )
                                .cornerRadius(25)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(Color.white.opacity(0.6), lineWidth: 1)
                                )
                                .shadow(color: .blue.opacity(0.5), radius: 8)
                                .shadow(color: .black.opacity(0.3), radius: 5, x: 2, y: 2)
                        }
                    }
                    
                    Button {
                        withAnimation {
                            gameState.resetGame()
                            gameState.isHomeScreen = false
                        }
                    } label: {
                        Text("New Game")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                            .frame(width: 200, height: 50)
                            .background(
                                LinearGradient(colors: [.green.opacity(0.8), .green.opacity(0.6)],
                                             startPoint: .topLeading,
                                             endPoint: .bottomTrailing)
                            )
                            .cornerRadius(25)
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color.white.opacity(0.6), lineWidth: 1)
                            )
                            .shadow(color: .green.opacity(0.5), radius: 8)
                            .shadow(color: .black.opacity(0.3), radius: 5, x: 2, y: 2)
                    }
                }
                .padding(.bottom, 50)
            }
            .padding(.horizontal)
        }
    }
}

struct HomeButton: View {
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white.opacity(0.2))
                )
        }
    }
}

// Helper extension for glow effect
extension View {
    func glow(color: Color, radius: CGFloat) -> some View {
        self
            .shadow(color: color, radius: radius / 2)
            .shadow(color: color, radius: radius / 2)
    }
}

// Helper extension for hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
} 