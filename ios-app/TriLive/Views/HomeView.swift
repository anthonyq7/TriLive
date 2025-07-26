import SwiftUI
import CoreLocation


struct HomeView: View {
    @ObservedObject var favoritesManager: FavoritesManager
    @ObservedObject var stopVM: StopViewModel
    @ObservedObject var timeManager: TimeManager
    @ObservedObject var locationManager: LocationManager
    @Binding var navigationPath: NavigationPath
    @Binding var favoriteRouteIDs: Set<Int>

    @State private var searchQuery = ""
    @FocusState private var isSearchFocused: Bool
    @State private var focusedRoute: Route?

    var body: some View {
        ZStack {
            Color("AppBackground").ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    ExtractedLogoAndWelcomeView()
                        .padding(.top)

                    // — SearchBar pulled above the list —
                    SearchBar(
                        locationManager: locationManager,
                        searchQuery:     $searchQuery,
                        stopSelected:    Binding(get: { stopVM.selectedStop != nil }, set: { _ in }),
                        selectedStop:    $stopVM.selectedStop,
                        stopList:        stopVM.filteredStops,
                        isFocused:       $isSearchFocused
                    )
                    .padding()
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                    .padding(.horizontal)
                    .onChange(of: searchQuery, perform: stopVM.filter)
                    .zIndex(2)

                    // — Route results under the search bar —
                    if let stop = stopVM.selectedStop {
                        VStack(alignment: .leading, spacing: 16) {
                            Text(stop.name)
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal)

                            LazyVStack(spacing: 16) {
                                ForEach(stopVM.routes) { route in
                                    RouteCard(
                                        parentStop: stop,
                                        line:       route,
                                        isSelected: focusedRoute == route,
                                        isFavorited: favoriteRouteIDs.contains(route.routeId),
                                        onTap:      { confirmOrHighlight(route) },
                                        onFavoriteTapped: { toggleFavorite(route) }
                                    )
                                    .padding()
                                    .cornerRadius(16)
                                    .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 3)
                                    .padding(.horizontal)
                                }
                            }
                            .animation(.easeIn, value: stopVM.routes)
                            .padding(.bottom, 24)
                        }
                        .zIndex(0)
                    }

                    Spacer(minLength: 50)
                }
                .padding(.vertical, 24)
            }

            selectionOverlay
        }
        .onAppear { Task { await stopVM.loadStops() } }
        .onTapGesture { isSearchFocused = false }
        .onChange(of: stopVM.selectedStop) { newStop in
            if let s = newStop {
                stopVM.startPollingArrivals(for: s)
            } else {
                stopVM.stopPollingArrivals()
                stopVM.arrivals = []
                stopVM.routes   = []
            }
            focusedRoute = nil
        }
        .alert("Error loading stops", isPresented: $stopVM.showError) {
            Button("OK", role: .cancel) { stopVM.showError = false }
        } message: {
            Text(stopVM.errorMessage ?? "Unknown error")
        }
        .navigationDestination(for: Route.self) { route in
            if let parent = stopVM.selectedStop {
                RouteDetailView(
                    parentStop:  parent,
                    route:       route,
                    stopVM:      stopVM,
                    navPath:     $navigationPath,
                    timeManager: timeManager
                )
            }
        }
    }
    
    // Confirm overlay
    @ViewBuilder
    private var selectionOverlay: some View {
        if let stop = stopVM.selectedStop,
           let r  = focusedRoute,
           let arrival = stopVM.arrivals.first(where: { $0.routeId == r.id && $0.eta == r.eta_unix }) {
            
            VisualEffectBlur(blurStyle: .systemThinMaterialDark)
                .ignoresSafeArea()
                .zIndex(1)
            
            VStack(spacing: 16) {
                let model = Route(
                    stopId:     stop.id,
                    routeId:    arrival.routeId,
                    routeName:  arrival.routeName,
                    status:     arrival.status,
                    eta:        "\(arrival.minutesUntilArrival)",
                    routeColor: arrival.routeColor,
                    eta_unix:   arrival.eta
                )
                
                RouteCard(
                    parentStop:  stop,
                    line:        model,
                    isSelected:  true,
                    isFavorited: favoriteRouteIDs.contains(model.routeId),
                    onTap:       { navigate(to: model) },
                    onFavoriteTapped: {
                        toggleFavorite(model)
                        focusedRoute = nil
                    }
                )
                .padding()
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                
                Text("Tap again to confirm, or Cancel below")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                
                Button(action: { focusedRoute = nil }) {
                    Text("Cancel")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("StopColor"))
                        .cornerRadius(16)
                }
                .padding(.horizontal, 40)
            }
            .zIndex(2)
        }
    }
    
    // Helpers
    private func confirmOrHighlight(_ route: Route) {
        if focusedRoute == route {
            navigate(to: route)
        } else {
            focusedRoute = route
        }
    }
    
    private func navigate(to route: Route) {
        navigationPath.append(route)
        timeManager.startTimer()
        focusedRoute = nil
    }
    
    private func toggleFavorite(_ route: Route) {
        if favoriteRouteIDs.contains(route.routeId) {
            favoriteRouteIDs.remove(route.routeId)
        } else {
            favoriteRouteIDs.insert(route.routeId)
        }
    }
}
