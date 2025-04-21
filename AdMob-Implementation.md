# AdMob Implementation Guide for VeggieCatcher

This document explains how AdMob has been integrated into the VeggieCatcher game.

## Implementation Overview

The AdMob integration follows these key principles:
- Interstitial ads show every 4 levels
- Rewarded ads are available when user clicks on reward buttons
- No banner ads are implemented

## Files Modified

1. **AdManager.swift**
   - Updated to implement real AdMob SDK functionality
   - Added delegates for interstitial and rewarded ads
   - Maintained the same API interface to ensure compatibility

2. **VeggieCatcher-Info.plist**
   - Contains the `GADApplicationIdentifier` app ID

## Required Configuration

### 1. Add the Google Mobile Ads SDK

1. In Xcode, select your project in the Project Navigator
2. Select File > Add Packages
3. Enter the package URL: https://github.com/googleads/swift-package-manager-google-mobile-ads
4. Click "Add Package"

### 2. Info.plist Configuration

The project uses the `VeggieCatcher-Info.plist` file, which already contains:
```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-2130442199452399~2043636993</string>
```

Make sure to add these additional entries to the same file:

```xml
<key>NSUserTrackingUsageDescription</key>
<string>This identifier will be used to deliver personalized ads to you.</string>

<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>

<key>SKAdNetworkItems</key>
<array>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>cstr6suwn9.skadnetwork</string>
    </dict>
    <!-- Additional SKAdNetwork identifiers as needed -->
</array>
```

## Testing Ads

During development, the app uses test ad units to prevent invalid activity:
- Test Interstitial Ad ID: `ca-app-pub-3940256099942544/4411468910`
- Test Rewarded Ad ID: `ca-app-pub-3940256099942544/1712485313`

## Production Setup

Before publishing to the App Store:
1. Set `useTestAds` flag in `AdManager.swift` to `false`
2. Make sure your production ad unit IDs are correct:
   - Interstitial Ad ID: `ca-app-pub-2130442199452399/1525698027`
   - Rewarded Ad ID: `ca-app-pub-2130442199452399/1586603319`

## How Ads Work in the Game

- **Interstitial Ads**: Automatically show every 4 levels through the existing `AdIntegration.showInterstitialAdIfNeeded(forLevel:completion:)` method.

- **Rewarded Ads**: Available through the `AdIntegration.showRewardedAd(completion:)` method, which provides a callback with a boolean indicating if the user earned the reward.

## Troubleshooting

If ads are not appearing:
1. Check the Xcode console for detailed error messages
2. Verify network connectivity
3. Ensure the ad unit IDs are correct
4. Make sure Info.plist contains all required configuration

For detailed logs about ad loading and presentation, check the console output which includes emoji markers for easy identification:
- 📱 General ad information
- 🔄 Ad loading
- ✅ Successful operations
- ❌ Errors
- ⭐ Rewarded ad events
- 📊 Ad metrics 