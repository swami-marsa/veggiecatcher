import SwiftUI

/// A manager class for handling ads in the app
class AdManager: ObservableObject {
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
    private let useTestAds = true // ALWAYS TRUE DURING DEVELOPMENT
    
    // MARK: - Initialization
    
    /// Private initializer for singleton
    private init() {
        print("AdManager initialized")
        // Make sure test ads are immediately available
        setTestAdsReady()
    }
    
    // MARK: - Public Methods
    
    /// Get the appropriate interstitial ad ID (always returns test ID during development)
    private func getInterstitialAdID() -> String {
        // Force using test IDs during development
        return testInterstitialAdID
    }
    
    /// Get the appropriate rewarded ad ID (always returns test ID during development)
    private func getRewardedAdID() -> String {
        // Force using test IDs during development
        return testRewardedAdID
    }
    
    /// Make test ads immediately ready for testing
    func setTestAdsReady() {
        print("✅ TEST ADS: Setting test ads as ready")
        DispatchQueue.main.async {
            self.isInterstitialAdReady = true
            self.isRewardedAdReady = true
        }
    }
    
    /// Initialize the ad system
    func initialize() {
        // Log which ad IDs we're using
        print("📱 USING TEST AD IDs ONLY IN DEV MODE:")
        print("🔄 Test Interstitial ID: \(testInterstitialAdID)")
        print("⭐ Test Rewarded ID: \(testRewardedAdID)")
        
        // Make test ads immediately available
        setTestAdsReady()
    }
    
    /// Check if an interstitial ad should be shown for the given level
    /// - Parameter level: Current level in the game
    /// - Returns: Boolean indicating if an ad should be shown
    func shouldShowInterstitialAd(forLevel level: Int) -> Bool {
        guard areAdsEnabled else { return false }
        guard isInterstitialAdReady else { return false }
        
        // Show an ad every 4 levels (4, 8, 12, etc.)
        // The correct formula is level % levelsBetweenInterstitials == 0
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
        guard areAdsEnabled, isInterstitialAdReady else {
            print("❌ Interstitial ad not ready or disabled")
            completion()
            return
        }
        
        print("📱 Showing test interstitial ad with ID: \(getInterstitialAdID())")
        
        // Set ad as not ready to prevent multiple shows
        isInterstitialAdReady = false
        
        // For stub implementation, simulate ad showing and dismissal with delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            print("✅ Test interstitial ad dismissed")
            
            // Load next ad before calling completion
            self.prepareInterstitialAd()
            completion()
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
        guard areAdsEnabled, isRewardedAdReady else {
            print("❌ Rewarded ad not ready or disabled")
            completion(false)
            return
        }
        
        print("📱 Showing test rewarded ad with ID: \(getRewardedAdID())")
        
        // Set ad as not ready immediately to prevent multiple shows
        isRewardedAdReady = false
        
        // For stub implementation, simulate ad showing and reward with delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            print("⭐ Test rewarded ad completed, giving reward")
            
            // Load next ad
            self.prepareRewardedAd()
            
            // Deliver the reward
            completion(true)
        }
    }
    
    /// Prepare interstitial ad for display
    func prepareInterstitialAd() {
        guard areAdsEnabled else { return }
        
        print("🔄 Preparing test interstitial ad")
        
        // Simulate ad loading
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isInterstitialAdReady = true
            print("✅ Test interstitial ad ready")
        }
    }
    
    /// Prepare rewarded ad for display
    func prepareRewardedAd() {
        guard areAdsEnabled else { return }
        
        print("🔄 Preparing test rewarded ad")
        
        // Simulate ad loading
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isRewardedAdReady = true
            print("✅ Test rewarded ad ready")
        }
    }
} 