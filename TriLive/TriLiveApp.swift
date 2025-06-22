//
//  TriLiveApp.swift
//  TriLive
//
//  Created by Anthony Qin on 6/6/25.
//

import SwiftUI

@main
struct TriLiveApp: App {
    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                // Once splash is done, show main tabs
                MainTabView()
                    .opacity(showSplash ? 0 : 1)

                // Always load SplashView on top initially
                if showSplash {
                    SplashView()
                        .transition(.opacity)
                }
            }
            .onAppear {
                // Keep splash on screen for 2 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation(.easeOut(duration: 0.5)) {
                        showSplash = false
                    }
                }
            }
        }
    }
}
