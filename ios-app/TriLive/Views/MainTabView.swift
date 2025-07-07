//  MainTabView.swift
//  TriLive

import SwiftUI

struct MainTabView: View {
  @State private var selectedTab     = Tab.home
  @State private var favoriteRouteIDs = Set<Int>()
  @State private var navigationPath  = NavigationPath()
  @StateObject private var timeManager = TimeManager()
  @StateObject private var stopVM       = StopViewModel()

  var body: some View {
    TabView(selection: $selectedTab) {
      NavigationStack(path: $navigationPath) {
        HomeView(
          favoriteRouteIDs: $favoriteRouteIDs,
          locationManager:  LocationManager(),
          timeManager:      timeManager,
          navigationPath:   $navigationPath
        )
      }
      .tabItem { Label("Home", systemImage: "bus.fill") }
      .tag(Tab.home)

      FavoritesView(
        favoriteRouteIDs: $favoriteRouteIDs,
        navPath:          $navigationPath,
        stops:            stopVM.allStops,
        timeManager:      timeManager
      )
      .tabItem { Label("Favorites", systemImage: "star.fill") }
      .tag(Tab.favorites)

      SettingsView()
        .tabItem { Label("Settings", systemImage: "gearshape.fill") }
        .tag(Tab.settings)
    }
    .onAppear { stopVM.loadStops() }
    .preferredColorScheme(.dark)
  }
}

extension MainTabView {
  enum Tab: Hashable { case home, favorites, settings }
}
