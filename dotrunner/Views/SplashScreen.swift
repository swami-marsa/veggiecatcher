import SwiftUI

struct SplashScreen: View {
    @ObservedObject var gameState: GameState
    @State private var isAnimating = false
    @State private var showMainContent = false
    private let deviceManager = DeviceManager.shared
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background image with device-specific handling
                Image(deviceManager.splashBackgroundImage())
                    .resizable()
                    .aspectRatio(contentMode: .fill) // Always use fill for splash
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .ignoresSafeArea()
                
                // Animated logo container
                VStack(spacing: deviceManager.isIpad ? 30 : 20) {
                    // App icon instead of game logo
                    Image(uiImage: UIImage(named: "AppIcon") ?? UIImage())
                        .resizable()
                        .scaledToFit()
                        .frame(width: deviceManager.splashLogoSize(), height: deviceManager.splashLogoSize())
                        .cornerRadius(deviceManager.splashLogoCornerRadius())
                        .scaleEffect(isAnimating ? 1.1 : 0.9)
                        .opacity(isAnimating ? 1 : 0.5)
                        .animation(
                            Animation.easeInOut(duration: 1.0)
                                .repeatForever(autoreverses: true),
                            value: isAnimating
                        )
                    
                    // Game title
                    Text("Veggie")
                        .font(.system(size: deviceManager.splashTitleSize(), weight: .bold))
                        .foregroundColor(.white)
                        .opacity(isAnimating ? 1 : 0)
                        .offset(y: isAnimating ? 0 : 20)
                    
                    Text("Catcher")
                        .font(.system(size: deviceManager.splashSubtitleSize(), weight: .semibold))
                        .foregroundColor(.green)
                        .opacity(isAnimating ? 1 : 0)
                        .offset(y: isAnimating ? 0 : 20)
                    
                    // Loading indicator
                    ZStack {
                        Circle()
                            .stroke(lineWidth: deviceManager.splashLoaderStrokeWidth())
                            .frame(width: deviceManager.splashLoaderSize(), height: deviceManager.splashLoaderSize())
                            .foregroundColor(.gray.opacity(0.3))
                        
                        Circle()
                            .trim(from: 0, to: 0.7)
                            .stroke(lineWidth: deviceManager.splashLoaderStrokeWidth())
                            .frame(width: deviceManager.splashLoaderSize(), height: deviceManager.splashLoaderSize())
                            .foregroundColor(.white)
                            .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                            .animation(
                                Animation.linear(duration: 1)
                                    .repeatForever(autoreverses: false),
                                value: isAnimating
                            )
                    }
                    .opacity(isAnimating ? 1 : 0)
                }
            }
        }
        .ignoresSafeArea()
        .onAppear {
            isAnimating = true
            
            // Transition to main content after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation(.easeOut(duration: 0.5)) {
                    showMainContent = true
                }
            }
        }
        .opacity(showMainContent ? 0 : 1)
        .onChange(of: showMainContent) { _, newValue in
            if newValue {
                gameState.isHomeScreen = true
            }
        }
    }
} 