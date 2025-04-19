import SwiftUI

struct RewardedAdView: View {
    /// Callback when reward is earned
    var onRewardEarned: () -> Void
    
    /// Callback when offer is declined
    var onDecline: () -> Void
    
    /// Device manager for consistent sizing
    private let deviceManager = DeviceManager.shared
    
    var body: some View {
        VStack(spacing: deviceManager.isIpad ? 30 : 20) {
            // Title
            Text("Get Extra Life")
                .font(.system(size: deviceManager.isIpad ? 34 : 24, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .shadow(color: .black, radius: 2, x: 1, y: 1)
            
            // Description
            Text("Watch a short video to get an extra life")
                .font(.system(size: deviceManager.isIpad ? 24 : 18))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.bottom, deviceManager.isIpad ? 20 : 10)
                .shadow(color: .black, radius: 1, x: 1, y: 1)
            
            // Buttons
            VStack(spacing: deviceManager.isIpad ? 20 : 15) {
                // Watch Ad button
                Button(action: {
                    AdIntegration.showRewardedAd { success in
                        if success {
                            onRewardEarned()
                        } else {
                            // Ad failed or was skipped
                            onDecline()
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
        .padding(deviceManager.isIpad ? 40 : 30)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.blue.opacity(0.8))
                .shadow(color: .black.opacity(0.5), radius: 10)
        )
    }
} 