import SwiftUI
import CoreLocation

struct HomeView: View {
    @Binding var favoriteRouteIDs: Set<Int>
    @ObservedObject var locationManager: LocationManager
    @ObservedObject var timeManager: TimeManager
    @Binding var navigationPath: NavigationPath
    @ObservedObject var stopVM: StopViewModel
    @Binding var selectedStop: Stop?
    
    @State private var searchQuery       = ""
    @FocusState private var isSearchFocused: Bool
    @State private var focusedRouteID: Int?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                ExtractedLogoAndWelcomeView()
                
                SearchBar(
                    locationManager: locationManager,
                    searchQuery:     $searchQuery,
                    stopSelected:    Binding(
                        get:  { stopVM.selectedStop != nil },
                        set:  { _ in }
                    ),
                    selectedStop:    $stopVM.selectedStop,
                    stopList:        stopVM.filteredStops,
                    isFocused:       $isSearchFocused
                )
                .onChange(of: searchQuery, perform: stopVM.filter)
                .zIndex(1)
                
                // only show when a stop is chosen
                if let stop = stopVM.selectedStop {
                    LazyVStack(spacing: 12) {
                        ForEach(stopVM.routes) { route in
                            RouteCard(
                                parentStop:  stop,
                                line:        route,
                                isSelected:  focusedRouteID == route.routeId,
                                isFavorited: favoriteRouteIDs.contains(route.routeId),
                                onTap:       { confirmOrHighlight(route) },
                                onFavoriteTapped: { toggleFavorite(route) },
                            )
                            .padding(.horizontal, 12)
                        }
                    }
                    .animation(.easeIn, value: stopVM.routes)
                    .padding(.top, 12)
                }
                
                Spacer()
            }
            .padding(.top, 24)
        }
        .onTapGesture {
            isSearchFocused = false
        }
        .background(Color("AppBackground").ignoresSafeArea())
        .onAppear { Task { await stopVM.loadStops() } }
        .alert("Error loading stops", isPresented: $stopVM.showError) {
            Button("OK", role: .cancel) { stopVM.showError = false }
        } message: {
            Text(stopVM.errorMessage ?? "Unknown")
        }
        .onChange(of: stopVM.selectedStop) {
            if let s = $0 { stopVM.startPollingArrivals(for: s) }
            else      { stopVM.stopPollingArrivals(); stopVM.arrivals=[]; stopVM.routes=[] }
        }
        .navigationDestination(for: Route.self) { route in
            if let parent = stopVM.selectedStop {
                RouteDetailView(
                    parentStop: parent,
                    route:      route,
                    stopVM:     stopVM,
                    navPath:    $navigationPath,
                    timeManager: timeManager
                )
            }
        }
    }
    
    private func confirmOrHighlight(_ route: Route) {
        if focusedRouteID == route.routeId {
            navigationPath.append(route)
            focusedRouteID = nil
            timeManager.startTimer()
        } else {
            focusedRouteID = route.routeId
        }
    }
    
    private func toggleFavorite(_ route: Route) {
        if favoriteRouteIDs.contains(route.routeId) {
            favoriteRouteIDs.remove(route.routeId)
        } else {
            favoriteRouteIDs.insert(route.routeId)
        }
    }
}
