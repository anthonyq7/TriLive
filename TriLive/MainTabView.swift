import SwiftUI
import Combine
import CoreLocation

struct MainTabView: View {
    @State private var selectedTab = Tab.home
    @State private var favoriteRouteIDs = Set<Int>()
    @State private var navigationPath = NavigationPath()
    @State private var activitiyStarted: Bool = false
    @State private var locationManager = LocationManager()
    @StateObject var timeManager = TimeManager()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            NavigationStack {
                HomeView(favoriteRouteIDs: $favoriteRouteIDs, locationManager: locationManager, timeManager: timeManager, navigationPath: $navigationPath)
                    .navigationDestination(for: Route.self) { route in
                        let stop = stops.first {$0.routeList.contains { $0.id == route.id}}!
                        
                        RouteDetailView(parentStop: stop, route: route, navPath: $navigationPath, timeManager: timeManager)
                    }
            }
            .tabItem { Label("Home", systemImage: "bus.fill") }
            .tag(Tab.home)
            .preferredColorScheme(.dark)
            
            FavoritesView(
                favoriteRouteIDs: $favoriteRouteIDs,
                navPath: $navigationPath,
                stops: stops,
                timeManager: timeManager
            )
            .tabItem {
                Image(systemName: "star.fill")
                Text("Favorites")
            }
            .tag(Tab.favorites)
            .preferredColorScheme(.dark)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
                .tag(Tab.settings)
                .preferredColorScheme(.dark)
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
