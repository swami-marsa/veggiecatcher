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
    
    /// Test interstitial ad unit ID
    private let testInterstitialAdID = "ca-app-pub-3940256099942544/4411468910"
    
    /// Test rewarded ad unit ID
    private let testRewardedAdID = "ca-app-pub-3940256099942544/1712485313"
    
    // MARK: - Initialization
    
    /// Private initializer for singleton
    private init() {
        print("AdManager initialized")
    }
    
    // MARK: - Public Methods
    
    /// Initialize the ad system
    func initialize() {
        print("AdManager would initialize with app ID: \(appID)")
    }
    
    /// Check if an interstitial ad should be shown for the given level
    /// - Parameter level: Current level in the game
    /// - Returns: Boolean indicating if an ad should be shown
    func shouldShowInterstitialAd(forLevel level: Int) -> Bool {
        guard isInterstitialAdReady else { return false }
        
        // Show an ad every 3 levels (example logic)
        return level > 1 && level % 3 == 0
    }
    
    /// Show an interstitial ad if one is available
    /// - Parameter completion: Callback to execute after ad is dismissed
    func showInterstitialAd(completion: @escaping () -> Void) {
        print("Would show interstitial ad")
        
        // Simulate ad showing and dismissal
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion()
        }
    }
    
    /// Check if a rewarded ad is available to show
    /// - Returns: Boolean indicating if a rewarded ad can be shown
    func isRewardedAdAvailable() -> Bool {
        return isRewardedAdReady
    }
    
    /// Show a rewarded ad if one is available
    /// - Parameter completion: Callback with boolean indicating if reward should be given
    func showRewardedAd(completion: @escaping (Bool) -> Void) {
        print("Would show rewarded ad")
        
        // Simulate ad showing and reward
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion(true)
        }
    }
    
    /// Prepare interstitial ad for display
    func prepareInterstitialAd() {
        print("Would prepare interstitial ad with ID: \(interstitialAdID)")
        
        // Simulate ad loading
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isInterstitialAdReady = true
            print("Interstitial ad ready")
        }
    }
    
    /// Prepare rewarded ad for display
    func prepareRewardedAd() {
        print("Would prepare rewarded ad with ID: \(rewardedAdID)")
        
        // Simulate ad loading
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isRewardedAdReady = true
            print("Rewarded ad ready")
        }
    }
} 