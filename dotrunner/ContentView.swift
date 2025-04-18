//
//  ContentView.swift
//  dotrunner
//
//  Created by Swaminathan  on 17/11/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var gameState = GameState()
    @State private var showSplash = true
    @AppStorage("isMusicEnabled") private var isMusicEnabled = true
    @AppStorage("isSoundEffectsEnabled") private var isSoundEffectsEnabled = true
    
    var body: some View {
        ZStack {
            if showSplash {
                SplashScreen(gameState: gameState)
                    .transition(.opacity)
                    .onAppear {
                        // Start music when app launches
                        if isMusicEnabled {
                            SoundManager.shared.playBackgroundMusic("game_home")
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                            withAnimation {
                                showSplash = false
                            }
                        }
                    }
            } else if gameState.isHomeScreen {
                HomeScreen(gameState: gameState)
            } else {
                GameView(gameState: gameState)
            }
        }
        .onAppear {
            // Initialize sound settings with saved preferences
            SoundManager.shared.setMusicEnabled(isMusicEnabled)
            SoundManager.shared.setEffectsEnabled(isSoundEffectsEnabled)
        }
    }
}

#Preview {
    ContentView()
}
