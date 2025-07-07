import SwiftUI

struct MainTabView: View {
    @Binding var favoriteRouteIDs: Set<Int>
    @ObservedObject var locationManager: LocationManager
    @ObservedObject var timeManager: TimeManager
    @Binding var navigationPath: NavigationPath

    // Local view model for stops
    @StateObject private var stopVM = StopViewModel()

    // Local UI state
    @State private var selectedTab = Tab.debug

    var body: some View {
        TabView(selection: $selectedTab) {
            // Debug tab
            NavigationStack(path: $navigationPath) {
                DebugStopsView()
            }
            .tabItem { Label("Debug", systemImage: "ant.fill") }
            .tag(Tab.debug)

            // Home tab
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

            // Favorites tab
            NavigationStack(path: $navigationPath) {
                FavoritesView(
                    favoriteRouteIDs: $favoriteRouteIDs,
                    navPath:          $navigationPath,
                    stops:            stopVM.allStops,
                    timeManager:      timeManager
                )
            }
            .tabItem { Label("Favorites", systemImage: "star.fill") }
            .tag(Tab.favorites)

            // Settings tab
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
                .tag(Tab.settings)
        }
        .onAppear {
            stopVM.loadStops()
            // kick off stop loading once
        }
        .preferredColorScheme(.dark)
    }
}

extension MainTabView {
    enum Tab: Hashable {
        case debug, home, favorites, settings
    }
}

struct DebugStopsView: View {
    @State private var names: [String] = []

    var body: some View {
        List(names, id: \.self) { Text($0) }
            .task {
                StopService.shared.fetchStops { result in
                    switch result {
                    case .success(let stops):
                        DispatchQueue.main.async {
                            self.names = stops.map(\.name)
                        }
                    case .failure(let err):
                        print("Fetch stops failed:", err)
                    }
                }
            }
    }
}
