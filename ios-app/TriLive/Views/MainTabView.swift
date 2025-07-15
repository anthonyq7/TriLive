import SwiftUI

struct MainTabView: View {
    //Store Set<Int> in UserDefaults as JSON
    @AppStorage("favoriteRoutesData") private var favoriteRoutesData: Data = Data()
    private var favoriteRouteIDs: Binding<Set<Int>> {
        Binding(
            get: {
                (try? JSONDecoder().decode(Set<Int>.self, from: favoriteRoutesData)) ?? []
            },
            set: { newValue in
                favoriteRoutesData = (try? JSONEncoder().encode(newValue)) ?? Data()
            }
        )
    }

    //Shared managers
    @StateObject private var locationManager = LocationManager()
    @StateObject private var timeManager     = TimeManager()

    //Independent nav paths per tab
    @State private var homePath = NavigationPath()
    @State private var favsPath = NavigationPath()

    // for which tab is selected
    @State private var selectedTab = Tab.home

    var body: some View {
        TabView(selection: $selectedTab) {
            //Home
            NavigationStack(path: $homePath) {
                HomeView(
                    favoriteRouteIDs: favoriteRouteIDs,
                    locationManager:  locationManager,
                    timeManager:      timeManager,
                    navigationPath:   $homePath
                )
            }
            .tabItem { Label("Home", systemImage: "bus.fill") }
            .tag(Tab.home)

            //Favorites
            NavigationStack(path: $favsPath) {
                FavoritesView(
                    favoriteRouteIDs: favoriteRouteIDs,
                    navPath:          $favsPath,
                    timeManager:      timeManager
                )
            }
            .tabItem { Label("Favorites", systemImage: "star.fill") }
            .tag(Tab.favorites)

            //Settings
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
                .tag(Tab.settings)
        }
        .preferredColorScheme(.dark)
    }
}

extension MainTabView {
    enum Tab: Hashable {
        case home, favorites, settings
    }
}
