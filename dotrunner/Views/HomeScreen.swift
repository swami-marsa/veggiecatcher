import SwiftUI

struct HomeScreen: View {
    @ObservedObject var gameState: GameState
    @AppStorage("isMusicEnabled") private var isMusicEnabled = true
    @AppStorage("isSoundEffectsEnabled") private var isSoundEffectsEnabled = true
    private let deviceManager = DeviceManager.shared
    
    var body: some View {
        GeometryReader { geometry in
        ZStack {
                // Background image with proper scaling for iPad
                Image(deviceManager.homeBackgroundImage())
                    .interpolation(.high)
                    .resizable()
                    .aspectRatio(contentMode: .fill) // Always use fill
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .ignoresSafeArea()
                
                if deviceManager.isIpad {
                    // IPAD LAYOUT
                    iPadLayout(geometry: geometry, gameState: gameState)
                } else {
                    // IPHONE LAYOUT
                    iPhoneLayout(geometry: geometry, gameState: gameState)
                }
            }
        }
        .ignoresSafeArea()
        .statusBar(hidden: true)
        .onAppear {
            // Start playing home screen music if enabled
            if isMusicEnabled {
                SoundManager.shared.playBackgroundMusic(Constants.Sounds.gameHome)
            }
            
            // Debug the continue button condition
            print("DEBUG: lastPlayedLevel = \(gameState.lastPlayedLevel)")
            print("DEBUG: isGameOver = \(gameState.isGameOver)")
            print("DEBUG: highestLevelReached = \(gameState.highestLevelReached)")
            print("DEBUG: continuationScore = \(gameState.continuationScore)")
            print("DEBUG: Continue button should show: \(gameState.lastPlayedLevel >= 1 && (gameState.continuationScore > 0 || gameState.highestLevelReached > 1))")
            print("DEBUG: Device is iPad: \(deviceManager.isIpad)")
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
    
    // MARK: - iPad Layout
    private func iPadLayout(geometry: GeometryProxy, gameState: GameState) -> some View {
        VStack(spacing: 0) {
            // Top spacing for iPad - pushes content to middle
            Spacer()
                .frame(height: geometry.size.height * 0.4)
            
            // Controls section for iPad
            HStack {
                // High Score Section
                if gameState.highScore > 0 {
                    HStack(spacing: 12) {
                        Image(systemName: "trophy.fill")
                            .font(.system(size: deviceManager.homeTrophyIconSize()))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.5), radius: 3, x: 1, y: 1)
                        
                        Text("\(gameState.highScore)")
                            .font(.system(size: deviceManager.homeTrophyTextSize(), weight: .heavy))
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.5), radius: 3, x: 1, y: 1)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .frame(minWidth: deviceManager.homeScoreFrameMinWidth())
                    .background(
                        RoundedRectangle(cornerRadius: deviceManager.homeTrophyBackgroundRadius())
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
                            .shadow(color: .black.opacity(0.5), radius: 5, x: 2, y: 2) // 3D shadow
                    )
                } else {
                    // Show a placeholder for consistent layout
                    Spacer()
                        .frame(width: deviceManager.homeScoreFrameMinWidth())
                }
                
                Spacer()
                
                // Sound Controls
                HStack(spacing: 20) {
                    // Music Toggle
                    Button(action: {
                        isMusicEnabled.toggle()
                        SoundManager.shared.setMusicEnabled(isMusicEnabled)
                        if isMusicEnabled {
                            SoundManager.shared.playBackgroundMusic(Constants.Sounds.gameHome)
                        }
                    }) {
                        Image(systemName: isMusicEnabled ? "music.note" : "speaker.slash.circle.fill")
                            .font(.system(size: deviceManager.homeSoundIconSize(), weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: deviceManager.homeSoundButtonSize(), height: deviceManager.homeSoundButtonSize())
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
                                        lineWidth: 3
                                    )
                            )
                            .shadow(color: .black.opacity(0.5), radius: 5, x: 2, y: 2) // 3D shadow
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
                            .font(.system(size: deviceManager.homeSoundIconSize(), weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: deviceManager.homeSoundButtonSize(), height: deviceManager.homeSoundButtonSize())
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
                                        lineWidth: 3
                                    )
                            )
                            .shadow(color: .black.opacity(0.5), radius: 5, x: 2, y: 2) // 3D shadow
                            .scaleEffect(isSoundEffectsEnabled ? 1.0 : 0.9)
                    }
                }
            }
            .padding(.horizontal, 20)
            
            // iPad-specific spacing
            Spacer()
                .frame(height: geometry.size.height * 0.1)
                
            // Game logo for iPad
            Image(uiImage: UIImage(named: "AppIcon") ?? UIImage())
                .resizable()
                .interpolation(.high)
                .antialiased(true)
                .scaledToFit()
                .frame(width: deviceManager.homeLogoSize(), height: deviceManager.homeLogoSize())
                .cornerRadius(deviceManager.homeLogoBorderRadius())
                .shadow(color: .white.opacity(0.5), radius: 10)
                .glow(color: .blue, radius: 20)
            
            Spacer()
            
            // Game Buttons
            gameButtons(gameState: gameState)
                .padding(.bottom, 80)
        }
        .padding(.horizontal)
    }
    
    // MARK: - iPhone Layout
    private func iPhoneLayout(geometry: GeometryProxy, gameState: GameState) -> some View {
        VStack(spacing: 0) {
            // Logo section
            Spacer()
                .frame(height: 60) // Fixed top spacing for iPhone
                
            // Game logo for iPhone
            Image(uiImage: UIImage(named: "AppIcon") ?? UIImage())
                .resizable()
                .interpolation(.high)
                .antialiased(true)
                .scaledToFit()
                .frame(width: deviceManager.homeLogoSize(), height: deviceManager.homeLogoSize())
                .cornerRadius(deviceManager.homeLogoBorderRadius())
                .shadow(color: .white.opacity(0.5), radius: 10)
                .glow(color: .blue, radius: 20)
            
            // Controls section - ADJUST THIS VALUE TO MOVE CONTROLS DOWN
            Spacer()
                .frame(height: 100) // <-- CHANGE THIS VALUE to move controls further down
                
            // Controls section for iPhone
                HStack {
                // High Score Section
                    if gameState.highScore > 0 {
                        HStack(spacing: 8) {
                            Image(systemName: "trophy.fill")
                            .font(.system(size: deviceManager.homeTrophyIconSize()))
                                .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.5), radius: 3, x: 1, y: 1)
                            
                            Text("\(gameState.highScore)")
                            .font(.system(size: deviceManager.homeTrophyTextSize(), weight: .heavy))
                                .minimumScaleFactor(0.5)
                                .lineLimit(1)
                                .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.5), radius: 3, x: 1, y: 1)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    .frame(minWidth: deviceManager.homeScoreFrameMinWidth())
                        .background(
                        RoundedRectangle(cornerRadius: deviceManager.homeTrophyBackgroundRadius())
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
                            .shadow(color: .black.opacity(0.5), radius: 5, x: 2, y: 2) // 3D shadow
                        )
                } else {
                    // Show a placeholder for consistent layout
                    Spacer()
                        .frame(width: deviceManager.homeScoreFrameMinWidth())
                    }
                    
                    Spacer()
                    
                // Sound Controls
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
                            .font(.system(size: deviceManager.homeSoundIconSize(), weight: .bold))
                                .foregroundColor(.white)
                            .frame(width: deviceManager.homeSoundButtonSize(), height: deviceManager.homeSoundButtonSize())
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
                            .shadow(color: .black.opacity(0.5), radius: 5, x: 2, y: 2) // 3D shadow
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
                            .font(.system(size: deviceManager.homeSoundIconSize(), weight: .bold))
                                .foregroundColor(.white)
                            .frame(width: deviceManager.homeSoundButtonSize(), height: deviceManager.homeSoundButtonSize())
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
                            .shadow(color: .black.opacity(0.5), radius: 5, x: 2, y: 2) // 3D shadow
                                .scaleEffect(isSoundEffectsEnabled ? 1.0 : 0.9)
                    }
                }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Game Buttons
            gameButtons(gameState: gameState)
                .padding(.bottom, 50)
        }
        .padding(.horizontal)
    }
    
    // MARK: - Shared Game Buttons
    private func gameButtons(gameState: GameState) -> some View {
        VStack(spacing: deviceManager.isIpad ? 40 : 25) {
            // Show Continue button only if player has any progress
            // For a fresh game, lastPlayedLevel is 1 and continuationScore is 0
            // After completing level 1, lastPlayedLevel is still 1 but continuationScore is not 0
            if gameState.lastPlayedLevel >= 1 && (gameState.continuationScore > 0 || gameState.highestLevelReached > 1) {
                        Button {
                            withAnimation {
                                gameState.continueGame()
                                gameState.isHomeScreen = false
                            }
                        } label: {
                    HStack {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.system(size: deviceManager.homeButtonTextSize()))
                        Text("Continue Journey")
                            .font(.system(size: deviceManager.homeButtonTextSize(), weight: .bold))
                    }
                    .gameButtonStyle(colors: [.purple.opacity(0.8), .blue.opacity(0.7)])
                    .overlay(
                        Text("Level \(max(2, gameState.lastPlayedLevel + 1))")
                            .deviceSpecificFont(size: 12, weight: .bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(Color.black.opacity(0.6))
                            .cornerRadius(12)
                            .offset(y: deviceManager.isIpad ? 50 : 40)
                    )
                }
                .padding(.bottom, deviceManager.isIpad ? 20 : 10)
                    }
                    
                    Button {
                        withAnimation {
                            gameState.resetGame()
                            gameState.isHomeScreen = false
                        }
                    } label: {
                HStack {
                    Image(systemName: "play.fill")
                        .font(.system(size: deviceManager.homeButtonTextSize()))
                    Text("New Adventure")
                        .font(.system(size: deviceManager.homeButtonTextSize(), weight: .bold))
                }
                .gameButtonStyle(colors: [.orange.opacity(0.8), .red.opacity(0.7)])
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

// MARK: - Preview Provider

#Preview {
    Group {
        HomeScreen(gameState: GameState())
            .previewDisplayName("iPhone")
            .previewDevice(PreviewDevice(rawValue: "iPhone 15 Pro"))
            .environment(\.horizontalSizeClass, .compact)
            .environment(\.verticalSizeClass, .regular)
            
        HomeScreen(gameState: GameState())
            .previewDisplayName("iPad")
            .previewDevice(PreviewDevice(rawValue: "iPad Pro (12.9-inch) (6th generation)"))
            .environment(\.horizontalSizeClass, .regular)
            .environment(\.verticalSizeClass, .regular)
    }
} 