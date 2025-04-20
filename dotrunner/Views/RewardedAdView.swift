import SwiftUI

struct RewardedAdView: View {
    /// Callback when reward is earned
    var onRewardEarned: () -> Void
    
    /// Callback when offer is declined
    var onDecline: () -> Void
    
    /// Show loading indicator
    @State private var isLoading = false
    
    /// Show success indicator
    @State private var showSuccess = false
    
    /// Device manager for consistent sizing
    private let deviceManager = DeviceManager.shared
    
    var body: some View {
        VStack(spacing: deviceManager.isIpad ? 30 : 20) {
            // Title
            Text(showSuccess ? "Reward Earned!" : "Get Extra Life")
                .font(.system(size: deviceManager.isIpad ? 34 : 24, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .shadow(color: .black, radius: 2, x: 1, y: 1)
            
            // Success icon or description
            if showSuccess {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.system(size: deviceManager.isIpad ? 60 : 40))
                    .padding(.bottom, deviceManager.isIpad ? 20 : 10)
            } else {
                Text("Watch a short video to get an extra life")
                    .font(.system(size: deviceManager.isIpad ? 24 : 18))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, deviceManager.isIpad ? 20 : 10)
                    .shadow(color: .black, radius: 1, x: 1, y: 1)
            }
            
            // Buttons or loading indicator
            if isLoading {
                // Loading indicator
                VStack {
                    ProgressView()
                        .scaleEffect(deviceManager.isIpad ? 2.0 : 1.5)
                        .padding()
                    
                    Text("Loading Ad...")
                        .foregroundColor(.white)
                        .font(.system(size: deviceManager.isIpad ? 20 : 16))
                }
            } else if showSuccess {
                // Continue button after success
                Button(action: {
                    onRewardEarned()
                }) {
                    Text("Continue")
                        .font(.system(size: deviceManager.isIpad ? 24 : 18, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, deviceManager.isIpad ? 30 : 20)
                        .padding(.vertical, deviceManager.isIpad ? 16 : 12)
                        .background(Color.green)
                        .cornerRadius(deviceManager.isIpad ? 25 : 20)
                        .shadow(color: .black.opacity(0.5), radius: 5)
                }
            } else {
                // Watch Ad and No Thanks buttons
                VStack(spacing: deviceManager.isIpad ? 20 : 15) {
                    // Watch Ad button
                    Button(action: {
                        // Set loading state
                        isLoading = true
                        
                        // Print debug info
                        print("📱 RewardedAdView: User pressed Watch Ad button")
                        print("📱 RewardedAdView: Ad available? \(AdIntegration.isRewardedAdAvailable())")
                        
                        // Force ads to be ready
                        AdManager.shared.prepareRewardedAd()
                        
                        // Delay slightly to ensure ad is loaded
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            // Try to show ad
                            AdIntegration.showRewardedAd { success in
                                print("📱 RewardedAdView: Ad completed with success = \(success)")
                                
                                // Reset loading state
                                isLoading = false
                                
                                if success {
                                    // Immediately deliver the reward
                                    onRewardEarned()
                                } else {
                                    // Ad failed or was skipped
                                    onDecline()
                                }
                            }
                        }
                    }) {
                        HStack {
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: deviceManager.isIpad ? 28 : 20))
                            Text("Watch Ad")
                                .font(.system(size: deviceManager.isIpad ? 24 : 18, weight: .bold))
                        }
                        .padding(.horizontal, deviceManager.isIpad ? 30 : 20)
                        .padding(.vertical, deviceManager.isIpad ? 16 : 12)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(deviceManager.isIpad ? 25 : 20)
                        .shadow(color: .black.opacity(0.5), radius: 5)
                    }
                    
                    // No Thanks button
                    Button(action: onDecline) {
                        Text("No Thanks")
                            .font(.system(size: deviceManager.isIpad ? 20 : 16, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, deviceManager.isIpad ? 20 : 15)
                            .padding(.vertical, deviceManager.isIpad ? 12 : 10)
                            .background(Color.gray.opacity(0.6))
                            .cornerRadius(deviceManager.isIpad ? 20 : 15)
                            .shadow(color: .black.opacity(0.3), radius: 3)
                    }
                }
            }
        }
        .padding(deviceManager.isIpad ? 40 : 30)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.blue.opacity(0.8))
                .shadow(color: .black.opacity(0.5), radius: 10)
        )
        .animation(.easeInOut(duration: 0.3), value: isLoading)
        .animation(.easeInOut(duration: 0.3), value: showSuccess)
        .onAppear {
            // Force ads to be ready when view appears
            AdManager.shared.setTestAdsReady()
            print("📱 RewardedAdView appeared, forcing ads to be ready")
        }
    }
} 