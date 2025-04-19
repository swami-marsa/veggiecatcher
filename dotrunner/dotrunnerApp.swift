//
//  dotrunnerApp.swift
//  dotrunner
//
//  Created by Swaminathan  on 17/11/24.
//

import SwiftUI

@main
struct dotrunnerApp: App {
    init() {
        // Initialize the ad manager
        AdManager.shared.initialize()
        
        // Prepare ads
        AdIntegration.prepareAds()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
