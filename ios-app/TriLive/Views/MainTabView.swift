import SwiftUI

struct MainTabView: View {
    @ObservedObject var favoritesManager: FavoritesManager
    @ObservedObject var stopVM:           StopViewModel
    @ObservedObject var timeManager:      TimeManager
    @ObservedObject var locationManager:  LocationManager

    @Binding var navigationPath: NavigationPath
    @Binding var selectedTab:    TabSelection

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(
                favoritesManager: favoritesManager,
                stopVM:           stopVM,
                timeManager:      timeManager,
                locationManager:  locationManager,
                navigationPath:   $navigationPath,
                favoriteRouteIDs:  $favoritesManager.favoriteRouteIDs
            )
            .tabItem { Label("Home", systemImage: "house.fill") }
            .tag(TabSelection.home)

            FavoritesView(
                favoritesManager: favoritesManager,
                stopVM:           stopVM,
                timeManager:      timeManager,
                navigationPath:   $navigationPath
            )
            .tabItem { Label("Favorites", systemImage: "star.fill") }
            .tag(TabSelection.favorites)

            SettingsView(locationManager: locationManager)
            .tabItem { Label("Settings", systemImage: "gearshape.fill") }
            .tag(TabSelection.settings)
        }
        .onChange(of: selectedTab) { tab in
            // When you go to Favorites, restart polling on all your favorites’ stops:
            if tab == .favorites {
                let stops = Set(favoritesManager.routes.map(\.stopId))
                for sid in stops {
                    if let s = stopVM.allStops.first(where: { $0.id == sid }) {
                        stopVM.startPollingArrivals(for: s)
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

