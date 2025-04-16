import SwiftUI

struct SplashScreen: View {
    @ObservedObject var gameState: GameState
    @State private var isAnimating = false
    @State private var showMainContent = false
    
    var body: some View {
        ZStack {
            // Background image
            Image("splash_background") // Dimensions: 1290x2796 px (iPhone 15 Pro Max)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            // Animated logo container
            VStack(spacing: 20) {
                // App icon instead of game logo
                Image(uiImage: UIImage(named: "AppIcon") ?? UIImage())
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .cornerRadius(40) // Match iOS app icon corner radius
                    .scaleEffect(isAnimating ? 1.1 : 0.9)
                    .opacity(isAnimating ? 1 : 0.5)
                    .animation(
                        Animation.easeInOut(duration: 1.0)
                            .repeatForever(autoreverses: true),
                        value: isAnimating
                    )
                
                // Game title
                Text("Veggie")
                    .font(.system(size: 60, weight: .bold))
                    .foregroundColor(.white)
                    .opacity(isAnimating ? 1 : 0)
                    .offset(y: isAnimating ? 0 : 20)
                
                Text("Catcher")
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundColor(.green)
                    .opacity(isAnimating ? 1 : 0)
                    .offset(y: isAnimating ? 0 : 20)
                
                // Loading indicator
                ZStack {
                    Circle()
                        .stroke(lineWidth: 4)
                        .frame(width: 40, height: 40)
                        .foregroundColor(.gray.opacity(0.3))
                    
                    Circle()
                        .trim(from: 0, to: 0.7)
                        .stroke(lineWidth: 4)
                        .frame(width: 40, height: 40)
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