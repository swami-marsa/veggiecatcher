import SwiftUI
import GoogleMobileAds

/// A manager class for handling ads in the app
class AdManager: NSObject, ObservableObject {
    /// Shared singleton instance
    static let shared = AdManager()
    
    // MARK: - Published Properties
    
    /// Flag indicating if an interstitial ad is ready to show
    @Published var isInterstitialAdReady = false
    
    /// Flag indicating if a rewarded ad is ready to show
    @Published var isRewardedAdReady = false
    
    // MARK: - Properties
    
    /// The AdMob app ID
    private let appID = "ca-app-pub-2130442199452399~2043636993"
    
    /// The interstitial ad unit ID
    private let interstitialAdID = "ca-app-pub-2130442199452399/1525698027"
    
    /// The rewarded ad unit ID
    private let rewardedAdID = "ca-app-pub-2130442199452399/1586603319"
    
    /// Test interstitial ad unit ID - DO NOT CHANGE (official Google test ID)
    private let testInterstitialAdID = "ca-app-pub-3940256099942544/4411468910"
    
    /// Test rewarded ad unit ID - DO NOT CHANGE (official Google test ID)
    private let testRewardedAdID = "ca-app-pub-3940256099942544/1712485313"
    
    /// Number of levels between interstitial ads
    private let levelsBetweenInterstitials = 4
    
    /// Flag to enable/disable ads (for testing)
    @AppStorage("areAdsEnabled") private var areAdsEnabled = true
    
    /// Flag to use test ads instead of production ads
    /// IMPORTANT: Set to false before submitting to App Store
    private let useTestAds = false // Set to false for production
    
    // MARK: - AdMob Properties
    
    /// The loaded interstitial ad
    private var interstitialAd: InterstitialAd?
    
    /// The loaded rewarded ad
    private var rewardedAd: RewardedAd?
    
    /// Completion handler for interstitial ad
    private var interstitialCompletion: (() -> Void)?
    
    /// Completion handler for rewarded ad
    private var rewardedCompletion: ((Bool) -> Void)?
    
    // MARK: - Initialization
    
    /// Private initializer for singleton
    override private init() {
        super.init()
        print("AdManager initialized")
    }
    
    // MARK: - Public Methods
    
    /// Get the appropriate interstitial ad ID (test ID during development)
    private func getInterstitialAdID() -> String {
        return useTestAds ? testInterstitialAdID : interstitialAdID
    }
    
    /// Get the appropriate rewarded ad ID (test ID during development)
    private func getRewardedAdID() -> String {
        return useTestAds ? testRewardedAdID : rewardedAdID
    }
    
    /// Make test ads immediately ready for testing
    func setTestAdsReady() {
        if useTestAds {
            print("✅ TEST ADS: Setting test ads as ready")
            prepareInterstitialAd()
            prepareRewardedAd()
        }
    }
    
    /// Initialize the ad system
    func initialize() {
        // Initialize the Mobile Ads SDK
        MobileAds.initialize()
        print("📱 AdMob SDK initialized")
        
        // Log which ad IDs we're using
        if useTestAds {
            print("📱 USING TEST AD IDs IN DEV MODE:")
            print("🔄 Test Interstitial ID: \(testInterstitialAdID)")
            print("⭐ Test Rewarded ID: \(testRewardedAdID)")
        } else {
            print("📱 USING PRODUCTION AD IDs:")
            print("🔄 Interstitial ID: \(interstitialAdID)")
            print("⭐ Rewarded ID: \(rewardedAdID)")
        }
        
        // Prepare ads
        prepareInterstitialAd()
        prepareRewardedAd()
    }
    
    /// Get the root view controller
    private func getRootViewController() -> UIViewController? {
        // For iOS 15 and later
        if #available(iOS 15.0, *) {
            let scenes = UIApplication.shared.connectedScenes
            let windowScene = scenes.first as? UIWindowScene
            return windowScene?.windows.first?.rootViewController
        } else {
            // For iOS 14 and earlier
            return UIApplication.shared.windows.first?.rootViewController
        }
    }
    
    /// Check if an interstitial ad should be shown for the given level
    /// - Parameter level: Current level in the game
    /// - Returns: Boolean indicating if an ad should be shown
    func shouldShowInterstitialAd(forLevel level: Int) -> Bool {
        guard areAdsEnabled else { return false }
        guard isInterstitialAdReady else { return false }
        
        // Show an ad every 4 levels (4, 8, 12, etc.)
        let shouldShow = level > 0 && level % levelsBetweenInterstitials == 0
        
        // Debug output
        if shouldShow {
            print("✅ Interstitial ad should show for level \(level)")
        } else {
            print("❌ Interstitial ad should NOT show for level \(level) - Level check: \(level % levelsBetweenInterstitials == 0)")
        }
        return shouldShow
    }
    
    /// Show an interstitial ad if one is available
    /// - Parameter completion: Callback to execute after ad is dismissed
    func showInterstitialAd(completion: @escaping () -> Void) {
        guard areAdsEnabled, isInterstitialAdReady, let interstitialAd = interstitialAd else {
            print("❌ Interstitial ad not ready or disabled")
            completion()
            return
        }
        
        print("📱 Showing interstitial ad with ID: \(getInterstitialAdID())")
        
        // Set ad as not ready to prevent multiple shows
        isInterstitialAdReady = false
        interstitialCompletion = completion
        
        // Get the root view controller to present the ad
        if let rootViewController = getRootViewController() {
            interstitialAd.present(from: rootViewController)
        } else {
            print("❌ No root view controller found to present interstitial ad")
            completion()
            prepareInterstitialAd()
        }
    }
    
    /// Check if a rewarded ad is available to show
    /// - Returns: Boolean indicating if a rewarded ad can be shown
    func isRewardedAdAvailable() -> Bool {
        let isAvailable = areAdsEnabled && isRewardedAdReady
        print("📱 Rewarded ad available: \(isAvailable)")
        return isAvailable
    }
    
    /// Show a rewarded ad if one is available
    /// - Parameter completion: Callback with boolean indicating if reward should be given
    func showRewardedAd(completion: @escaping (Bool) -> Void) {
        guard areAdsEnabled, isRewardedAdReady, let rewardedAd = rewardedAd else {
            print("❌ Rewarded ad not ready or disabled")
            completion(false)
            return
        }
        
        print("📱 Showing rewarded ad with ID: \(getRewardedAdID())")
        
        // Set ad as not ready immediately to prevent multiple shows
        isRewardedAdReady = false
        rewardedCompletion = completion
        
        // Get the root view controller to present the ad
        if let rootViewController = getRootViewController() {
            rewardedAd.present(from: rootViewController, userDidEarnRewardHandler: {
                // This callback is triggered when the reward is earned
                let reward = rewardedAd.adReward
                print("⭐ User earned reward: \(reward.amount) \(reward.type)")
                self.rewardedCompletion?(true)
                self.rewardedCompletion = nil
            })
        } else {
            print("❌ No root view controller found to present rewarded ad")
            completion(false)
            prepareRewardedAd()
        }
    }
    
    /// Prepare interstitial ad for display
    func prepareInterstitialAd() {
        guard areAdsEnabled else { return }
        
        print("🔄 Preparing interstitial ad")
        
        let request = Request()
        InterstitialAd.load(with: getInterstitialAdID(), request: request) { [weak self] ad, error in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ Failed to load interstitial ad: \(error.localizedDescription)")
                return
            }
            
            print("✅ Interstitial ad loaded successfully")
            self.interstitialAd = ad
            self.interstitialAd?.fullScreenContentDelegate = self
            
            DispatchQueue.main.async {
                self.isInterstitialAdReady = true
            }
        }
    }
    
    /// Prepare rewarded ad for display
    func prepareRewardedAd() {
        guard areAdsEnabled else { return }
        
        print("🔄 Preparing rewarded ad")
        
        let request = Request()
        RewardedAd.load(with: getRewardedAdID(), request: request) { [weak self] ad, error in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ Failed to load rewarded ad: \(error.localizedDescription)")
                return
            }
            
            print("✅ Rewarded ad loaded successfully")
            self.rewardedAd = ad
            self.rewardedAd?.fullScreenContentDelegate = self
            
            DispatchQueue.main.async {
                self.isRewardedAdReady = true
            }
        }
    }
}

// MARK: - FullScreenContentDelegate
extension AdManager: FullScreenContentDelegate {
    /// Called when an ad impression is recorded
    func adDidRecordImpression(_ ad: FullScreenPresentingAd) {
        print("📊 Ad impression recorded")
    }
    
    /// Called when an ad is clicked
    func adDidRecordClick(_ ad: FullScreenPresentingAd) {
        print("📊 Ad click recorded")
    }
    
    /// Called when an ad fails to present
    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("❌ Ad failed to present: \(error.localizedDescription)")
        
        // Reset flags and reload ads
        DispatchQueue.main.async {
            if ad as? InterstitialAd == self.interstitialAd {
                self.interstitialCompletion?()
                self.interstitialCompletion = nil
                self.prepareInterstitialAd()
            } else if ad as? RewardedAd == self.rewardedAd {
                self.rewardedCompletion?(false)
                self.rewardedCompletion = nil
                self.prepareRewardedAd()
            }
        }
    }
    
    /// Called just before an ad is presented
    func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("📱 Ad will present")
    }
    
    /// Called when an ad is dismissed
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("📱 Ad was dismissed")
        
        // Handle callbacks and reload ads
        DispatchQueue.main.async {
            if ad as? InterstitialAd == self.interstitialAd {
                self.interstitialCompletion?()
                self.interstitialCompletion = nil
                self.prepareInterstitialAd()
            } else if ad as? RewardedAd == self.rewardedAd {
                // Note: For rewarded ads, the reward should already be handled
                // via the userDidEarnReward callback
                // This is just cleanup
                if let completion = self.rewardedCompletion {
                    // If the completion is still set, it means the reward wasn't earned
                    completion(false)
                    self.rewardedCompletion = nil
                }
                self.prepareRewardedAd()
            }
        }
    }
} 