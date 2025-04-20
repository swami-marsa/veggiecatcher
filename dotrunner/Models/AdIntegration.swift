import SwiftUI

/// Utility class that provides simple methods for using ads in the app
struct AdIntegration {
    /// Show an interstitial ad if appropriate for the current level
    /// - Parameters:
    ///   - level: Current game level
    ///   - completion: Callback for when the ad is dismissed
    static func showInterstitialAdIfNeeded(forLevel level: Int, completion: @escaping () -> Void) {
        if AdManager.shared.shouldShowInterstitialAd(forLevel: level) {
            print("Showing interstitial ad for level \(level) (divisible by 4)")
            AdManager.shared.showInterstitialAd(completion: completion)
        } else {
            print("No interstitial ad shown for level \(level) (not divisible by 4 or ad not ready)")
            // No ad to show, immediately call completion
            completion()
        }
    }
    
    /// Check if a rewarded ad is available to show
    /// - Returns: Boolean indicating if a rewarded ad can be shown
    static func isRewardedAdAvailable() -> Bool {
        let isAvailable = AdManager.shared.isRewardedAdAvailable()
        print("Rewarded ad available: \(isAvailable)")
        return isAvailable
    }
    
    /// Show a rewarded ad
    /// - Parameter completion: Callback with boolean indicating if reward was earned
    static func showRewardedAd(completion: @escaping (Bool) -> Void) {
        print("AdIntegration: Requesting to show rewarded ad")
        if AdManager.shared.isRewardedAdAvailable() {
            AdManager.shared.showRewardedAd { success in
                print("Rewarded ad completed with success: \(success)")
                completion(success)
                
                // Preload the next ad
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    AdManager.shared.prepareRewardedAd()
                }
            }
        } else {
            print("AdIntegration: Rewarded ad not available, cannot show")
            completion(false)
        }
    }
    
    /// Prepare ads for use in the app
    static func prepareAds() {
        print("AdIntegration: Preparing ads")
        AdManager.shared.prepareInterstitialAd()
        AdManager.shared.prepareRewardedAd()
    }
} 