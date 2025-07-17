import SwiftUI

struct MainTabView: View {
    // persist favorites locally
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

    // shared managers & VMs
    @StateObject private var locationManager = LocationManager()
    @StateObject private var timeManager     = TimeManager()
    @StateObject private var stopVM          = StopViewModel()
    @State private var selectedStop: Stop? = nil

    // nav paths
    @State private var homePath = NavigationPath()
    @State private var favsPath = NavigationPath()

    var body: some View {
        TabView {
            // Home tab
            NavigationStack(path: $homePath) {
                HomeView(
                    favoriteRouteIDs: favoriteRouteIDs,
                    locationManager:  locationManager,
                    timeManager:      timeManager,
                    navigationPath:   $homePath,
                    stopVM:           stopVM,
                    selectedStop:     $selectedStop
                )
            }
            .tabItem { Label("Home", systemImage: "bus.fill") }

            // Favorites tab
            NavigationStack(path: $favsPath) {
              FavoritesView(
                favoriteRouteIDs: favoriteRouteIDs,
                selectedStop:     $selectedStop,
                navPath:          $favsPath,
                timeManager:      timeManager,
                stopVM:           stopVM
              )
            }
            .tabItem { Label("Favorites", systemImage: "star.fill") }

            // Settings tab
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }
        .preferredColorScheme(.dark)
    }
}
