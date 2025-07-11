import SwiftUI

struct MainTabView: View {
    @Binding var favoriteRouteIDs: Set<Int>
    @ObservedObject var locationManager: LocationManager
    @ObservedObject var timeManager: TimeManager
    @Binding var navigationPath: NavigationPath

    // shared view model for stops & arrivals
    @StateObject private var stopVM = StopViewModel()

    // which tab is selected
    @State private var selectedTab = Tab.home

    var body: some View {
        TabView(selection: $selectedTab) {
            //Home tab
            NavigationStack(path: $navigationPath) {
                HomeView(
                    favoriteRouteIDs: $favoriteRouteIDs,
                    locationManager:  locationManager,
                    timeManager:      timeManager,
                    navigationPath:   $navigationPath
                )
            }
            .tabItem { Label("Home", systemImage: "bus.fill") }
            .tag(Tab.home)

            // MARK: – Favorites tab
            NavigationStack(path: $navigationPath) {
                FavoritesView(
                    favoriteRouteIDs: $favoriteRouteIDs,
                    navPath:          $navigationPath,
                    timeManager:      timeManager,
                )
            }
            .tabItem { Label("Favorites", systemImage: "star.fill") }
            .tag(Tab.favorites)

            //Settings tab
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
                .tag(Tab.settings)
        }
        .onAppear {
            stopVM.loadStops()    // preload stops & arrivals
        }
        .preferredColorScheme(.dark)
    }
}

extension MainTabView {
    enum Tab: Hashable {
        case debug, home, favorites, settings
    }
}

