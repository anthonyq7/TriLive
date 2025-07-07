//
//  TriLiveApp.swift
//  TriLive
//
//  Created by Anthony Qin on 6/6/25.
//

import SwiftUI

@main
struct TriLiveApp: App {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var timeManager     = TimeManager()
    @State private var navigationPath        = NavigationPath()
    @State private var favoriteRouteIDs: Set<Int> = []
    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                MainTabView(
                    favoriteRouteIDs: $favoriteRouteIDs,
                    locationManager:  locationManager,
                    timeManager:      timeManager,
                    navigationPath:   $navigationPath
                )
                .opacity(showSplash ? 0 : 1)

                if showSplash {
                    SplashView()
                        .transition(.opacity)
                }
            }
            .onAppear {
                // keep splash on screen for 2s
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation(.easeOut(duration: 0.5)) {
                        showSplash = false
                    }
                }
            }
        }
    }
}

