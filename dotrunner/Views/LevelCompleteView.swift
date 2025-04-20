import SwiftUI

struct LevelCompleteView: View {
    @ObservedObject var gameState: GameState
    @Environment(\.dismiss) private var dismiss
    @AppStorage("isMusicEnabled") private var isMusicEnabled = true
    @State private var showRewardedAdView = false
    @State private var showConfetti = true
    private let deviceManager = DeviceManager.shared
    
    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            // Confetti animation (if enabled)
            if showConfetti {
                ConfettiView()
                    .ignoresSafeArea()
                    .onAppear {
                        // Automatically disable confetti after a few seconds to save resources
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            showConfetti = false
                        }
                    }
            }
            
            // Main content container
            VStack(spacing: deviceManager.isIpad ? 30 : 20) {
                // Trophy icon
                Image(systemName: "trophy.fill")
                    .font(.system(size: deviceManager.isIpad ? 80 : 60))
                    .foregroundColor(.yellow)
                    .shadow(color: .orange, radius: 10, x: 0, y: 0)
                    .padding(.top, deviceManager.isIpad ? 20 : 10)
                
                // Level complete with level number
                HStack(spacing: deviceManager.isIpad ? 15 : 10) {
                    Text("LEVEL")
                        .font(.system(size: deviceManager.isIpad ? 34 : 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("\(gameState.level)")
                        .font(.system(size: deviceManager.isIpad ? 40 : 30, weight: .heavy))
                        .foregroundColor(.green)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 5)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.white.opacity(0.2))
                        )
                    
                    Text("DONE!")
                        .font(.system(size: deviceManager.isIpad ? 34 : 24, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(LinearGradient(
                            colors: [.purple.opacity(0.7), .blue.opacity(0.5)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                )
                .shadow(color: .black.opacity(0.5), radius: 10)
                
                // Score with star icon
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.system(size: deviceManager.isIpad ? 30 : 24))
                    
                    Text("\(gameState.score)")
                        .font(.system(size: deviceManager.isIpad ? 38 : 28, weight: .bold))
                        .foregroundColor(.yellow)
                        .shadow(color: .orange, radius: 2)
                }
                .padding(.top, deviceManager.isIpad ? 10 : 5)
                
                // Lives display
                HStack(spacing: deviceManager.isIpad ? 15 : 10) {
                    ForEach(0..<5, id: \.self) { index in
                        Image(systemName: index < gameState.remainingLives ? "heart.fill" : "heart")
                            .foregroundColor(.red)
                            .font(.system(size: deviceManager.isIpad ? 28 : 22))
                            .shadow(color: .pink.opacity(0.8), radius: 4)
                    }
                }
                .padding(.vertical, deviceManager.isIpad ? 15 : 10)
                
                // Buttons container
                VStack(spacing: deviceManager.isIpad ? 20 : 15) {
                    // Refill Lives Button (if needed and rewarded ad is available)
                    if gameState.remainingLives < 5 && AdIntegration.isRewardedAdAvailable() && !showRewardedAdView {
                        Button {
                            showRewardedAdView = true
                        } label: {
                            HStack {
                                Image(systemName: "play.circle.fill")
                                    .font(.system(size: deviceManager.isIpad ? 24 : 18))
                                
                                Image(systemName: "heart.fill")
                                    .font(.system(size: deviceManager.isIpad ? 24 : 18))
                                    .foregroundColor(.red)
                                
                                Text("Get Hearts")
                                    .font(.system(size: deviceManager.isIpad ? 24 : 18, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .frame(width: deviceManager.levelCompleteButtonWidth(), height: deviceManager.isIpad ? 70 : 50)
                            .background(
                                ZStack {
                                    RoundedRectangle(cornerRadius: deviceManager.isIpad ? 35 : 25)
                                        .fill(LinearGradient(
                                            colors: [.purple.opacity(0.8), .pink.opacity(0.6)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ))
                                    
                                    RoundedRectangle(cornerRadius: deviceManager.isIpad ? 35 : 25)
                                        .stroke(Color.white.opacity(0.6), lineWidth: 2)
                                }
                            )
                            .shadow(color: .purple.opacity(0.7), radius: deviceManager.isIpad ? 8 : 5)
                        }
                        .buttonStyle(BounceButtonStyle())
                    }
                    
                    // Next Level button
                    Button {
                        // Check if need to show interstitial ad
                        print("DEBUG: Checking for interstitial ad at level \(gameState.level)")
                        print("DEBUG: Should show ad calculation: level \(gameState.level) % 4 = \(gameState.level % 4)")
                        
                        AdIntegration.showInterstitialAdIfNeeded(forLevel: gameState.level) {
                            withAnimation {
                                gameState.startNextLevel()
                                if isMusicEnabled {
                                    SoundManager.shared.playBackgroundMusic("game_play")
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Text("Next Level")
                                .font(.system(size: deviceManager.isIpad ? 28 : 20, weight: .bold))
                            
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: deviceManager.isIpad ? 24 : 18))
                        }
                        .foregroundColor(.white)
                        .frame(width: deviceManager.levelCompleteButtonWidth(), height: deviceManager.isIpad ? 70 : 50)
                        .background(
                            ZStack {
                                RoundedRectangle(cornerRadius: deviceManager.isIpad ? 35 : 25)
                                    .fill(LinearGradient(
                                        colors: [.green.opacity(0.8), .green.opacity(0.6)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                                
                                RoundedRectangle(cornerRadius: deviceManager.isIpad ? 35 : 25)
                                    .stroke(Color.white.opacity(0.6), lineWidth: 2)
                            }
                        )
                        .shadow(color: .green.opacity(0.7), radius: deviceManager.isIpad ? 8 : 5)
                    }
                    .buttonStyle(BounceButtonStyle())
                    
                    // Home button
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
                        HStack {
                            Image(systemName: "house.fill")
                                .font(.system(size: deviceManager.isIpad ? 24 : 18))
                            
                            Text("Home")
                                .font(.system(size: deviceManager.isIpad ? 28 : 20, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(width: deviceManager.levelCompleteButtonWidth(), height: deviceManager.isIpad ? 70 : 50)
                        .background(
                            ZStack {
                                RoundedRectangle(cornerRadius: deviceManager.isIpad ? 35 : 25)
                                    .fill(LinearGradient(
                                        colors: [.blue.opacity(0.8), .blue.opacity(0.6)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                                
                                RoundedRectangle(cornerRadius: deviceManager.isIpad ? 35 : 25)
                                    .stroke(Color.white.opacity(0.6), lineWidth: 2)
                            }
                        )
                        .shadow(color: .blue.opacity(0.7), radius: deviceManager.isIpad ? 8 : 5)
                    }
                    .buttonStyle(BounceButtonStyle())
                }
                .padding(.top, deviceManager.isIpad ? 10 : 5)
            }
            .padding(deviceManager.isIpad ? 30 : 20)
            .background(
                RoundedRectangle(cornerRadius: deviceManager.isIpad ? 30 : 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.1, green: 0.1, blue: 0.3).opacity(0.9),
                                Color(red: 0.1, green: 0.2, blue: 0.4).opacity(0.85)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: deviceManager.isIpad ? 30 : 20)
                            .stroke(
                                LinearGradient(
                                    colors: [.yellow.opacity(0.6), .green.opacity(0.5), .blue.opacity(0.4)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: deviceManager.isIpad ? 3 : 2
                            )
                    )
                    .shadow(color: .purple.opacity(0.5), radius: deviceManager.isIpad ? 20 : 10)
            )
            .frame(width: min(UIScreen.main.bounds.width - (deviceManager.isIpad ? 100 : 40), deviceManager.isIpad ? 700 : 500))
            
            // Show the rewarded ad view if needed
            if showRewardedAdView {
                Color.black.opacity(0.7)
                    .ignoresSafeArea()
                    .onTapGesture {
                        // Prevent dismissing by tapping outside
                    }
                
                RewardedAdView(
                    onRewardEarned: {
                        showRewardedAdView = false
                        // Refill all lives to 5
                        withAnimation {
                            gameState.refillAllLives()
                            
                            // Log that lives have been refilled
                            print("Lives refilled from LevelCompleteView. Current lives: \(gameState.remainingLives)")
                        }
                    },
                    onDecline: {
                        showRewardedAdView = false
                    }
                )
                .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.easeInOut, value: showRewardedAdView)
    }
}

// Simple confetti animation
struct ConfettiView: View {
    let colors: [Color] = [.red, .blue, .green, .yellow, .pink, .purple, .orange]
    let numberOfParticles = 100
    
    var body: some View {
        ZStack {
            ForEach(0..<numberOfParticles, id: \.self) { i in
                ConfettiParticle(color: colors[i % colors.count])
            }
        }
    }
}

struct ConfettiParticle: View {
    @State private var position = CGPoint(x: 0, y: 0)
    @State private var rotation = 0.0
    @State private var scale = 0.0
    @State private var opacity = 0.0
    
    let color: Color
    
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: 8, height: 8)
            .scaleEffect(scale)
            .opacity(opacity)
            .rotationEffect(Angle(degrees: rotation))
            .position(x: position.x, y: position.y)
            .onAppear {
                // Randomize initial position
                let screenWidth = UIScreen.main.bounds.width
                let screenHeight = UIScreen.main.bounds.height
                position = CGPoint(
                    x: CGFloat.random(in: 0...screenWidth),
                    y: CGFloat.random(in: -50...0)
                )
                
                withAnimation(.easeOut(duration: 1.0).delay(Double.random(in: 0...1.5))) {
                    scale = CGFloat.random(in: 0.5...1.0)
                    opacity = 1.0
                }
                
                withAnimation(.linear(duration: 3.0 + Double.random(in: 0...2.0)).delay(Double.random(in: 0...1.5))) {
                    position = CGPoint(
                        x: position.x + CGFloat.random(in: -200...200),
                        y: screenHeight + 100
                    )
                    rotation = Double.random(in: 0...720)
                    opacity = 0.0
                }
            }
    }
}

// Add a bounce effect to buttons
struct BounceButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
} 