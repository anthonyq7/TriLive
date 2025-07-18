//
//  TriLiveApp.swift
//  TriLive
//
//  Created by Anthony Qin on 6/6/25.
//

import SwiftUI

enum TabSelection: Int {
    case home = 0, favorites = 1, settings = 2
}

@main
struct TriLiveApp: App {
    @StateObject private var favoritesManager = FavoritesManager()
    @StateObject private var stopVM           = StopViewModel()
    @StateObject private var timeManager      = TimeManager()
    @StateObject private var locManager       = LocationManager()

    @State private var navPath     = NavigationPath()
    @State private var selectedTab = TabSelection.home

    var body: some Scene {
        WindowGroup {
            MainTabView(
                favoritesManager: favoritesManager,
                stopVM:           stopVM,
                timeManager:      timeManager,
                locationManager:  locManager,
                navigationPath:   $navPath,
                selectedTab:      $selectedTab
            )
            .preferredColorScheme(.dark)
        }
    }
}


