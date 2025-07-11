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
  @State private   var favoriteRouteIDs   = Set<Int>()
  @State private   var navPath            = NavigationPath()

  var body: some Scene {
    WindowGroup {
      MainTabView(
        favoriteRouteIDs: $favoriteRouteIDs,
        locationManager:  locationManager,
        timeManager:      timeManager,
        navigationPath:   $navPath
      )
    }
  }
}

