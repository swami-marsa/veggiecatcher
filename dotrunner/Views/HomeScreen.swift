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
                                SoundManager.shared.playBackgroundMusic(Constants.Sounds.gameHome)
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
                                SoundManager.shared.playSound(Constants.Sounds.swipe)
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
                            HStack {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                    .font(.title3)
                                Text("Continue Journey")
                                    .font(.title3.bold())
                            }
                            .foregroundColor(.white)
                            .frame(width: 280, height: 60)
                            .background(
                                LinearGradient(colors: [.purple.opacity(0.8), .blue.opacity(0.7)],
                                             startPoint: .topLeading,
                                             endPoint: .bottomTrailing)
                            )
                            .cornerRadius(30)
                            .overlay(
                                RoundedRectangle(cornerRadius: 30)
                                    .stroke(Color.white.opacity(0.6), lineWidth: 2)
                            )
                            .shadow(color: .blue.opacity(0.5), radius: 10)
                            .overlay(
                                Text("Level \(gameState.lastPlayedLevel + 1)")
                                    .font(.caption.bold())
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 4)
                                    .background(Color.black.opacity(0.6))
                                    .cornerRadius(12)
                                    .offset(y: 40)
                            )
                        }
                        .padding(.bottom, 10)
                    }
                    
                    Button {
                        withAnimation {
                            gameState.resetGame()
                            gameState.isHomeScreen = false
                        }
                    } label: {
                        HStack {
                            Image(systemName: "play.fill")
                                .font(.title3)
                            Text("New Adventure")
                                .font(.title3.bold())
                        }
                        .foregroundColor(.white)
                        .frame(width: 280, height: 60)
                        .background(
                            LinearGradient(colors: [.orange.opacity(0.8), .red.opacity(0.7)],
                                         startPoint: .topLeading,
                                         endPoint: .bottomTrailing)
                        )
                        .cornerRadius(30)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color.white.opacity(0.6), lineWidth: 2)
                        )
                        .shadow(color: .red.opacity(0.5), radius: 10)
                    }
                }
                .padding(.bottom, 50)
            }
            .padding(.horizontal)
        }
        .onAppear {
            // Start playing home screen music if enabled
            if isMusicEnabled {
                SoundManager.shared.playBackgroundMusic(Constants.Sounds.gameHome)
            }
        }
        .onDisappear {
            // Clean up any resources when view disappears
            // This prevents audio resource leaks
            if !gameState.isHomeScreen {
                // Only stop home music if we're actually leaving the home screen
                // (not just temporarily disappearing due to system UI)
                SoundManager.shared.stopSound(Constants.Sounds.gameHome)
            }
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
// Removed duplicate Color extension with init(hex:) as it's already defined in ViewExtensions.swift 