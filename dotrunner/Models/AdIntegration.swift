import SwiftUI

/// Utility class that provides simple methods for using ads in the app
struct AdIntegration {
    /// Show an interstitial ad if appropriate for the current level
    /// - Parameters:
    ///   - level: Current game level
    ///   - completion: Callback for when the ad is dismissed
    static func showInterstitialAdIfNeeded(forLevel level: Int, completion: @escaping () -> Void) {
        if AdManager.shared.shouldShowInterstitialAd(forLevel: level) {
            AdManager.shared.showInterstitialAd(completion: completion)
        } else {
            // No ad to show, immediately call completion
            completion()
        }
    }
    
    /// Check if a rewarded ad is available to show
    /// - Returns: Boolean indicating if a rewarded ad can be shown
    static func isRewardedAdAvailable() -> Bool {
        return AdManager.shared.isRewardedAdAvailable()
    }
    
    /// Show a rewarded ad
    /// - Parameter completion: Callback with boolean indicating if reward was earned
    static func showRewardedAd(completion: @escaping (Bool) -> Void) {
        AdManager.shared.showRewardedAd(completion: completion)
    }
    
    /// Prepare ads for use in the app
    static func prepareAds() {
        AdManager.shared.prepareInterstitialAd()
        AdManager.shared.prepareRewardedAd()
    }
} 