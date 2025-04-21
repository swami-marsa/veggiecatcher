import SwiftUI

struct SplashScreen: View {
    @ObservedObject var gameState: GameState
    @State private var isAnimating = false
    @State private var showMainContent = false
    @State private var veggieRotation = 0.0
    @State private var loadingProgress = 0.0
    @State private var bounceVeggies = false
    
    // For veggie animations
    @State private var veggie1Offset = CGSize.zero
    @State private var veggie2Offset = CGSize.zero
    @State private var veggie3Offset = CGSize.zero
    @State private var veggie4Offset = CGSize.zero
    
    private let deviceManager = DeviceManager.shared
    
    // MARK: - Device-specific vegetable sizes
    
    // Get the correct carrot size for current device
    private var carrotSize: CGFloat {
        return deviceManager.isIpad ? 70 : 50 // Only change iPad size
    }
    
    // Get the correct leaf size for current device
    private var leafSize: CGFloat {
        return deviceManager.isIpad ? 60 : 45 // Only change iPad size
    }
    
    // Get the correct apple size for current device
    private var appleSize: CGFloat {
        return deviceManager.isIpad ? 65 : 48 // Only change iPad size
    }
    
    // Get the correct leaf circle size for current device
    private var leafCircleSize: CGFloat {
        return deviceManager.isIpad ? 55 : 40 // Only change iPad size
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background image with device-specific handling
                Image(deviceManager.splashBackgroundImage())
                    .resizable()
                    .aspectRatio(contentMode: .fill) // Always use fill for splash
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .ignoresSafeArea()
                
                // Animated veggies bouncing around
                ZStack {
                    // Carrot
                    Image(systemName: "carrot")
                        .font(.system(size: carrotSize))
                        .foregroundColor(.orange)
                        .shadow(color: .black, radius: 2)
                        .offset(veggie1Offset)
                        .rotationEffect(.degrees(veggieRotation * 0.8))
                        .opacity(bounceVeggies ? 0.9 : 0)
                    
                    // Leaf (representing vegetables)
                    Image(systemName: "leaf.fill")
                        .font(.system(size: leafSize))
                        .foregroundColor(.green)
                        .shadow(color: .black, radius: 2)
                        .offset(veggie2Offset)
                        .rotationEffect(.degrees(veggieRotation * -1.2))
                        .opacity(bounceVeggies ? 0.9 : 0)
                    
                    // Apple for fruit
                    Image(systemName: "apple.logo")
                        .font(.system(size: appleSize))
                        .foregroundColor(.red)
                        .shadow(color: .black, radius: 2)
                        .offset(veggie3Offset)
                        .rotationEffect(.degrees(veggieRotation))
                        .opacity(bounceVeggies ? 0.9 : 0)
                    
                    // One more vegetable
                    Image(systemName: "leaf.circle.fill")
                        .font(.system(size: leafCircleSize))
                        .foregroundColor(.green.opacity(0.8))
                        .shadow(color: .black, radius: 2)
                        .offset(veggie4Offset)
                        .rotationEffect(.degrees(veggieRotation * -0.7))
                        .opacity(bounceVeggies ? 0.9 : 0)
                }
                
                // Animated logo container
                VStack(spacing: deviceManager.isIpad ? 30 : 20) {
                    // App icon with enhanced animation
                    Image(uiImage: UIImage(named: "AppIcon") ?? UIImage())
                        .resizable()
                        .scaledToFit()
                        .frame(width: deviceManager.splashLogoSize(), height: deviceManager.splashLogoSize())
                        .cornerRadius(deviceManager.splashLogoCornerRadius())
                        .shadow(color: .white.opacity(0.6), radius: 15)
                        .scaleEffect(isAnimating ? 1.1 : 0.9)
                        .rotation3DEffect(
                            .degrees(isAnimating ? 10 : -10),
                            axis: (x: 0, y: 1, z: 0)
                        )
                        .animation(
                            Animation.easeInOut(duration: 1.5)
                                .repeatForever(autoreverses: true),
                            value: isAnimating
                        )
                    
                    // Fun loading indicator - progress bar style with bouncy effect
                    VStack(spacing: 10) {
                        ZStack(alignment: .leading) {
                            // Background track
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: deviceManager.isIpad ? 250 : 200, height: deviceManager.isIpad ? 18 : 14)
                                .foregroundColor(.black.opacity(0.3))
                            
                            // Animated fill
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: (deviceManager.isIpad ? 250 : 200) * loadingProgress, height: deviceManager.isIpad ? 18 : 14)
                                .foregroundColor(.white)
                                .overlay(
                                    LinearGradient(
                                        colors: [.green, .orange, .green],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .shadow(color: .white.opacity(0.5), radius: 3)
                                .scaleEffect(y: isAnimating ? 1.1 : 1.0)
                                .animation(
                                    Animation.easeInOut(duration: 0.5)
                                        .repeatForever(autoreverses: true),
                                    value: isAnimating
                                )
                        }
                        
                        // Loading text that changes
                        Text(loadingText())
                            .font(.system(size: deviceManager.isIpad ? 20 : 16, weight: .medium))
                            .foregroundColor(.white)
                            .shadow(color: .black, radius: 2)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.black.opacity(0.3))
                            )
                    }
                    .opacity(isAnimating ? 1 : 0)
                }
            }
        }
        .ignoresSafeArea()
        .statusBar(hidden: true)
        .onAppear {
            startAnimations()
        }
        .opacity(showMainContent ? 0 : 1)
        .onChange(of: showMainContent) { _, newValue in
            if newValue {
                gameState.isHomeScreen = true
            }
        }
    }
    
    // Returns a different loading message based on progress
    private func loadingText() -> String {
        let messages = [
            "Getting veggies ready...",
            "Planting seeds...",
            "Watering crops...",
            "Growing veggies...",
            "Almost ready to play!"
        ]
        
        let index = min(Int(loadingProgress * Double(messages.count)), messages.count - 1)
        return messages[index]
    }
    
    // Start all animations
    private func startAnimations() {
        // Start main animation flag
        isAnimating = true
        
        // Animate veggie positions with random movements
        withAnimation(Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
            // Show veggies after a slight delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                bounceVeggies = true
            }
            
            // Randomize veggie positions - calculate size based on device
            if deviceManager.isIpad {
                // iPad-specific positions - larger and more spread out
                let size = 200.0
                veggie1Offset = CGSize(width: -size, height: -size)
                veggie2Offset = CGSize(width: size, height: -size * 0.8)
                veggie3Offset = CGSize(width: -size * 0.7, height: size * 0.7)
                veggie4Offset = CGSize(width: size * 0.8, height: size * 0.6)
            } else {
                // iPhone-specific positions - keep exactly as they were
                let size = 150.0
                veggie1Offset = CGSize(width: -size, height: -size)
                veggie2Offset = CGSize(width: size, height: -size * 0.8)
                veggie3Offset = CGSize(width: -size * 0.7, height: size * 0.7)
                veggie4Offset = CGSize(width: size * 0.8, height: size * 0.6)
            }
        }
        
        // Continuous rotation animation
        withAnimation(Animation.linear(duration: 6).repeatForever(autoreverses: false)) {
            veggieRotation = 360
        }
        
        // Animate the progress bar
        withAnimation(Animation.easeInOut(duration: 2.5)) {
            loadingProgress = 1.0
        }
        
        // Transition to main content after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation(.easeOut(duration: 0.7)) {
                showMainContent = true
            }
        }
    }
} 