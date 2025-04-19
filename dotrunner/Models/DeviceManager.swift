import SwiftUI
import UIKit

/// Manager for device-specific dimensions and properties
class DeviceManager {
    static let shared = DeviceManager()
    
    // MARK: - Device Detection
    
    // Identify device type
    var isIpad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    // Check for iPad Pro (large screen iPad)
    var isLargeIpad: Bool {
        guard isIpad else { return false }
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        return max(screenWidth, screenHeight) >= 1100 // iPad Pro 12.9" and larger
    }
    
    // Screen dimensions
    var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    
    var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
    
    // MARK: - Background Images
    
    // Background image based on device
    func homeBackgroundImage() -> String {
        return isIpad ? "splash_background_ipad" : "splash_background"
    }
    
    func splashBackgroundImage() -> String {
        return isIpad ? "splash_background_ipad" : "splash_background"
    }
    
    // MARK: - Game Play Elements (iPad Optimized)
    
    // Vegetable sizes - reduced from 2x to 1.5x for iPad
    func standardVegetableSize() -> CGFloat {
        return isLargeIpad ? 120 : (isIpad ? 110 : 80) // 1.5x for iPad instead of 2x
    }
    
    func bombSize() -> CGFloat {
        return isLargeIpad ? 100 : (isIpad ? 95 : 70) // 1.5x for iPad instead of 2x
    }
    
    func beetrootSize() -> CGFloat {
        return isLargeIpad ? 135 : (isIpad ? 125 : 90) // 1.5x for iPad instead of 2x
    }
    
    // Game UI elements
    func heartIconSize() -> CGFloat {
        return isLargeIpad ? 44 : (isIpad ? 38 : 22) // 2x for iPad
    }
    
    func levelTextSize() -> CGFloat {
        return isLargeIpad ? 48 : (isIpad ? 40 : 24) // 2x for iPad
    }
    
    func scoreIconSize() -> CGFloat {
        return isLargeIpad ? 32 : (isIpad ? 28 : 16) // 2x for iPad
    }
    
    func scoreTextSize() -> CGFloat {
        return isLargeIpad ? 32 : (isIpad ? 28 : 16) // 2x for iPad
    }
    
    func pauseButtonSize() -> CGFloat {
        return isLargeIpad ? 80 : (isIpad ? 70 : 40) // 2x for iPad
    }
    
    func pauseIconSize() -> CGFloat {
        return isLargeIpad ? 40 : (isIpad ? 35 : 20) // 2x for iPad
    }
    
    // Game progress UI
    func progressBarHeight() -> CGFloat {
        return isLargeIpad ? 20 : (isIpad ? 16 : 8) // 2x for iPad
    }
    
    func progressBarWidth() -> CGFloat {
        return isLargeIpad ? 560 : (isIpad ? 480 : 240) // 2x for iPad
    }
    
    func missedWarningTextSize() -> CGFloat {
        return isLargeIpad ? 40 : (isIpad ? 32 : 20) // 2x for iPad
    }
    
    func missedWarningPaddingBottom() -> CGFloat {
        return isLargeIpad ? 60 : (isIpad ? 50 : 20) // Added more bottom padding for iPad
    }
    
    // Game over and level complete screens
    func gameOverTitleSize() -> CGFloat {
        return isLargeIpad ? 64 : (isIpad ? 54 : 32)
    }
    
    func gameOverScoreSize() -> CGFloat {
        return isLargeIpad ? 48 : (isIpad ? 40 : 24)
    }
    
    func gameOverWidth() -> CGFloat {
        return isLargeIpad ? 500 : (isIpad ? 450 : 300)
    }
    
    func levelCompleteTitleSize() -> CGFloat {
        return isLargeIpad ? 64 : (isIpad ? 54 : 36)
    }
    
    func levelCompleteScoreSize() -> CGFloat {
        return isLargeIpad ? 48 : (isIpad ? 40 : 24)
    }
    
    func levelCompleteHighScoreSize() -> CGFloat {
        return isLargeIpad ? 40 : (isIpad ? 34 : 20)
    }
    
    func levelCompleteBonusSize() -> CGFloat {
        return isLargeIpad ? 40 : (isIpad ? 34 : 20)
    }
    
    func levelCompleteButtonWidth() -> CGFloat {
        return isLargeIpad ? 400 : (isIpad ? 350 : 220)
    }
    
    // MARK: - Splash Screen Dimensions
    
    func splashLogoSize() -> CGFloat {
        return isLargeIpad ? 350 : (isIpad ? 300 : 200)
    }
    
    func splashLogoCornerRadius() -> CGFloat {
        return isLargeIpad ? 70 : (isIpad ? 60 : 40)
    }
    
    func splashTitleSize() -> CGFloat {
        return isLargeIpad ? 100 : (isIpad ? 80 : 60)
    }
    
    func splashSubtitleSize() -> CGFloat {
        return isLargeIpad ? 80 : (isIpad ? 60 : 40)
    }
    
    func splashLoaderSize() -> CGFloat {
        return isLargeIpad ? 70 : (isIpad ? 60 : 40)
    }
    
    func splashLoaderStrokeWidth() -> CGFloat {
        return isLargeIpad ? 8 : (isIpad ? 6 : 4)
    }
    
    // MARK: - Home Screen Dimensions
    
    func homeTrophyIconSize() -> CGFloat {
        return isLargeIpad ? 42 : (isIpad ? 36 : 22)
    }
    
    func homeTrophyTextSize() -> CGFloat {
        return isLargeIpad ? 50 : (isIpad ? 44 : 26)
    }
    
    func homeScoreFrameMinWidth() -> CGFloat {
        return isLargeIpad ? 240 : (isIpad ? 200 : 120)
    }
    
    func homeTrophyBackgroundRadius() -> CGFloat {
        return isLargeIpad ? 24 : (isIpad ? 22 : 18)
    }
    
    func homeSoundButtonSize() -> CGFloat {
        return isLargeIpad ? 85 : (isIpad ? 75 : 45)
    }
    
    func homeSoundIconSize() -> CGFloat {
        return isLargeIpad ? 44 : (isIpad ? 38 : 22)
    }
    
    func homeLogoSize() -> CGFloat {
        return isLargeIpad ? 240 : (isIpad ? 200 : 140)
    }
    
    func homeLogoBorderRadius() -> CGFloat {
        return isLargeIpad ? 60 : (isIpad ? 50 : 35)
    }
    
    func homeButtonWidth() -> CGFloat {
        return isLargeIpad ? 460 : (isIpad ? 400 : 280)
    }
    
    func homeButtonHeight() -> CGFloat {
        return isLargeIpad ? 90 : (isIpad ? 80 : 60)
    }
    
    func homeButtonTextSize() -> CGFloat {
        return isLargeIpad ? 28 : (isIpad ? 24 : 17) // .title3 size
    }
    
    func homeButtonCornerRadius() -> CGFloat {
        return isLargeIpad ? 45 : (isIpad ? 40 : 30)
    }
    
    func homeTopPadding() -> CGFloat {
        // Much less top padding for iPad
        return isLargeIpad ? 60 : (isIpad ? 40 : 250)
    }
    
    func homeBottomPadding() -> CGFloat {
        return isLargeIpad ? 100 : (isIpad ? 80 : 50)
    }
    
    // MARK: - Deprecated (To Be Removed)
    
    // These methods were previously used but are now consolidated
    // Keeping temporarily for backward compatibility
    
    func backgroundContentMode() -> ContentMode {
        return .fill // Always use fill now
    }
    
    func soundButtonsTopPadding() -> CGFloat {
        return isLargeIpad ? 30 : (isIpad ? 20 : 0)
    }
    
    func soundButtonsTrailingPadding() -> CGFloat {
        return isLargeIpad ? 40 : (isIpad ? 30 : 20)
    }
    
    func trophyLeadingPadding() -> CGFloat {
        return isLargeIpad ? 40 : (isIpad ? 30 : 20)
    }
} 