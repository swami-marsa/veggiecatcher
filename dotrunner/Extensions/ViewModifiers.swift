import SwiftUI

// MARK: - Device Specific View Modifiers

/// Applies device-specific font size
struct DeviceSpecificFontModifier: ViewModifier {
    let baseSize: CGFloat
    let weight: Font.Weight
    
    init(baseSize: CGFloat, weight: Font.Weight = .regular) {
        self.baseSize = baseSize
        self.weight = weight
    }
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: DeviceManager.shared.isIpad ? baseSize * 1.4 : baseSize, weight: weight))
    }
}

/// Applies device-specific button style for common game buttons
struct GameButtonModifier: ViewModifier {
    let colors: [Color]
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(.white)
            .frame(width: DeviceManager.shared.homeButtonWidth(), height: DeviceManager.shared.homeButtonHeight())
            .background(
                LinearGradient(colors: colors,
                             startPoint: .topLeading,
                             endPoint: .bottomTrailing)
            )
            .cornerRadius(DeviceManager.shared.homeButtonCornerRadius())
            .overlay(
                RoundedRectangle(cornerRadius: DeviceManager.shared.homeButtonCornerRadius())
                    .stroke(Color.white.opacity(0.6), lineWidth: 2)
            )
            .shadow(color: colors[0].opacity(0.5), radius: 10)
    }
}

// MARK: - View Extensions

extension View {
    /// Apply device-specific font size
    func deviceSpecificFont(size: CGFloat, weight: Font.Weight = .regular) -> some View {
        self.modifier(DeviceSpecificFontModifier(baseSize: size, weight: weight))
    }
    
    /// Apply common game button style
    func gameButtonStyle(colors: [Color]) -> some View {
        self.modifier(GameButtonModifier(colors: colors))
    }
} 