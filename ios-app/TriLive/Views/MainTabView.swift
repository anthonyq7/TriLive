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
            NavigationStack(path: $navigationPath) {
                HomeView(
                    favoritesManager: favoritesManager,
                    stopVM:           stopVM,
                    timeManager:      timeManager,
                    locationManager:  locationManager,
                    navigationPath:   $navigationPath,
                    favoriteRouteIDs: $favoritesManager.favoriteRouteIDs
                )
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(TabSelection.home)
            
            SettingsView(locationManager: locationManager)
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
            .tag(TabSelection.settings)
        }
        .accentColor(Color("AccentColor"))
    }
}
