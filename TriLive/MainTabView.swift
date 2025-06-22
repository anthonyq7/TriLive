import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = Tab.home
    @State private var favoriteRouteIDs = Set<Int>()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            HomeView(favoriteRouteIDs: $favoriteRouteIDs)
                .tabItem {
                    Image(systemName: "bus.fill")
                    Text("Home")
                }
                .tag(Tab.home)
            
            FavoritesView(
                favoriteRouteIDs: $favoriteRouteIDs,
                stops: stops
            )
            .tabItem {
                Image(systemName: "star.fill")
                Text("Favorites")
            }
            .tag(Tab.favorites)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
                .tag(Tab.settings)
        }
    }
}

extension MainTabView {
    enum Tab: Hashable {
        case home, favorites, settings
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .preferredColorScheme(.dark)
    }
}
