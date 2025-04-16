import SwiftUI

// Extension for Color to support hex initialization
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
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// Extension for View to add shadow/glow effects
extension View {
    /// Add a glowing effect to the view
    func addGlow(color: Color, radius: CGFloat) -> some View {
        self
            .shadow(color: color, radius: radius / 2)
            .shadow(color: color, radius: radius / 2)
    }
    
    /// Apply a standard button style with custom width and color
    func customButtonStyle(width: CGFloat, color: Color) -> some View {
        self
            .font(.system(size: 18, weight: .bold))
            .foregroundColor(.white)
            .frame(width: width, height: 44)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        LinearGradient(
                            colors: [color, color.opacity(0.6)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: color.opacity(0.4), radius: 5, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        LinearGradient(
                            colors: [.white.opacity(0.6), .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 1.5
                    )
            )
    }
    
    /// Add screen shake animation
    func screenShake(offset: CGSize) -> some View {
        self.offset(x: offset.width, y: offset.height)
    }
    
    /// Make the view scale up and down like a heartbeat
    func heartbeat(enabled: Bool = true, intensity: CGFloat = 0.1, speed: Double = 1.0) -> some View {
        self.modifier(HeartbeatModifier(enabled: enabled, intensity: intensity, speed: speed))
    }
}

/// Modifier to create a heartbeat animation
struct HeartbeatModifier: ViewModifier {
    let enabled: Bool
    let intensity: CGFloat
    let speed: Double
    
    @State private var isAnimating = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isAnimating ? 1 + intensity : 1)
            .onAppear {
                guard enabled else { return }
                
                withAnimation(
                    Animation
                        .easeInOut(duration: 0.5 / speed)
                        .repeatForever(autoreverses: true)
                ) {
                    isAnimating = true
                }
            }
    }
} 