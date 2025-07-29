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
    @State private var isShowingSearchPage = false
    @State private var focusedRoute: Route?
    @Namespace private var searchNamespace
    
    var body: some View {
        ZStack {
            Color("AppBackground").ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    ExtractedLogoAndWelcomeView()
                        .padding(.top)
                    
                    // Collapsed Search Bar
                    if !isShowingSearchPage {
                        HStack(spacing: 12) {
                            Image(systemName: "magnifyingglass").foregroundColor(.gray)
                            Text(searchQuery.isEmpty ? "Search stops" : searchQuery)
                                .foregroundColor(searchQuery.isEmpty ? .gray : .primary)
                            Spacer()
                        }
                        .padding(.vertical, 14)
                        .padding(.horizontal, 20)
                        .background(Color("SearchBarBackground"))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 2)
                        .padding(.horizontal, 12)
                        .matchedGeometryEffect(id: "searchBar", in: searchNamespace)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                isShowingSearchPage = true
                            }
                        }
                    }
                    
                    // Stop Arrivals & Routes
                    if let stop = stopVM.selectedStop {
                        VStack(alignment: .leading, spacing: 16) {
                            if !stopVM.routes.isEmpty {
                                Text("\(stop.name) \(stop.dir ?? "")")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                
                                LazyVStack(spacing: 16) {
                                    ForEach(stopVM.routes) { route in
                                        RouteCard(
                                            parentStop: stop,
                                            line: route,
                                            isSelected: focusedRoute == route,
                                            isFavorited: favoriteRouteIDs.contains(route.routeId),
                                            onTap: { confirmOrHighlight(route) },
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
                            } else {
                                Text("No upcoming arrivals")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                            }
                        }
                    }
                    
                    Spacer(minLength: 50)
                }
                .padding(.vertical, 24)
            }
            
            // Expanded Search Page
            if isShowingSearchPage {
                SearchPageView(
                    searchQuery: $searchQuery,
                    selectedStop: $stopVM.selectedStop,
                    showSearchPage: $isShowingSearchPage,
                    locationManager: locationManager,
                    stopList: stopVM.filteredStops,
                    namespace: searchNamespace
                )
                .zIndex(2)
                .transition(.identity)
            }
            
            // Selection Overlay with animation
            ZStack {
                selectionOverlay
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: focusedRoute)
        }
        .onAppear { Task { await stopVM.loadStops() } }
        .onChange(of: stopVM.selectedStop) { newStop in
            if let s = newStop {
                stopVM.startPollingArrivals(for: s)
            } else {
                stopVM.stopPollingArrivals()
                stopVM.arrivals = []
                stopVM.routes = []
            }
            focusedRoute = nil
        }
        .onChange(of: navigationPath) { newPath in
            // When returning from RouteDetailView, re-fetch arrivals
            if newPath.isEmpty, let currentStop = stopVM.selectedStop {
                stopVM.stopPollingArrivals()    // stop previous polling
                stopVM.startPollingArrivals(for: currentStop) // restart fresh polling
            }
        }
        .alert("Error loading stops", isPresented: $stopVM.showError) {
            Button("OK", role: .cancel) { stopVM.showError = false }
        } message: {
            Text(stopVM.errorMessage ?? "Unknown error")
        }
        .navigationDestination(for: Route.self) { route in
            if let parent = stopVM.selectedStop {
                RouteDetailView(
                    parentStop: parent,
                    route: route,
                    stopVM: stopVM,
                    navPath: $navigationPath,
                    timeManager: timeManager
                )
            }
        }
    }
    
    @ViewBuilder
    private var selectionOverlay: some View {
        if let stop = stopVM.selectedStop,
           let r = focusedRoute,
           let arr = stopVM.arrivals.first(where: { $0.routeId == r.routeId && $0.eta == r.eta_unix }) {
            
            VisualEffectBlur(blurStyle: .systemThinMaterialDark)
                .ignoresSafeArea()
                .transition(.opacity)
            
            VStack(spacing: 16) {
                let model = Route(
                    stopId: stop.id,
                    routeId: arr.routeId,
                    routeName: arr.routeName,
                    status: arr.status,
                    eta: "\(arr.minutesUntilArrival)",
                    routeColor: arr.routeColor,
                    eta_unix: arr.eta,
                    vehicleId: arr.vehicleId
                )
                
                RouteCard(
                    parentStop: stop,
                    line: model,
                    isSelected: true,
                    isFavorited: favoriteRouteIDs.contains(model.routeId),
                    onTap: { withAnimation { navigate(to: model) } },
                    onFavoriteTapped: {
                        withAnimation { toggleFavorite(model) }
                        focusedRoute = nil
                    }
                )
                .padding()
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                
                Text("Tap again to confirm, or Cancel below")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                    .transition(.opacity)
                
                Button(action: {
                    withAnimation { focusedRoute = nil }
                }) {
                    Text("Cancel")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("StopColor"))
                        .cornerRadius(16)
                }
                .padding(.horizontal, 40)
                .transition(.opacity)
            }
            .padding(10)
        }
    }
    
    private func confirmOrHighlight(_ route: Route) {
        withAnimation {
            if focusedRoute == route {
                navigate(to: route)
            } else {
                focusedRoute = route
            }
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
