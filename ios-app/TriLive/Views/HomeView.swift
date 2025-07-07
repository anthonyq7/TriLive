import SwiftUI

struct HomeView: View {
    // injected from App entry-point
    @Binding var favoriteRouteIDs: Set<Int>
    @ObservedObject var locationManager: LocationManager
    @ObservedObject var timeManager: TimeManager
    @Binding var navigationPath: NavigationPath

    // search & focus state
    @State private var searchQuery = ""
    @FocusState private var isSearchFocused: Bool

    // stops & arrivals
    @StateObject private var stopVM = StopViewModel()

    // tap-to-highlight / confirmation
    @State private var focusedRouteID: Int?

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                // your grey app background
                Color("AppBackground")
                    .ignoresSafeArea()

                // main content
                ScrollView {
                    VStack(spacing: 24) {
                        ExtractedLogoAndWelcomeView()

                        SearchBar(
                            locationManager: locationManager,
                            searchQuery:     $searchQuery,
                            stopSelected:    Binding(
                                                 get: { stopVM.selectedStop != nil },
                                                 set: { _ in }
                                             ),
                            selectedStop:    $stopVM.selectedStop,
                            stopList:        stopVM.filteredStops,
                            isFocused:       $isSearchFocused
                        )
                        .onChange(of: searchQuery) { stopVM.filter(query: $0) }
                        .zIndex(1)

                        if let stop = stopVM.selectedStop {
                            Group {
                                if stopVM.isLoadingArrivals {
                                    ProgressView("Loading arrivals…")
                                } else if stopVM.showArrivalsError {
                                    Text("Error: \(stopVM.arrivalsErrorMessage ?? "Unknown")")
                                        .foregroundColor(.red)
                                } else {
                                    LazyVStack(spacing: 12) {
                                        ForEach(stopVM.arrivals) { arrival in
                                            // build a Route from the Arrival
                                            let route = Route(
                                                id:           arrival.route,
                                                name:         "\(arrival.route)",
                                                arrivalTime:  arrival.scheduled,
                                                direction:    "",
                                                realTime:     arrival.estimated ?? arrival.scheduled,
                                                isMAX:        false
                                            )
                                            RouteCard(
                                                parentStop:    stop,
                                                line:          route,
                                                isSelected:    focusedRouteID == route.id,
                                                onTap:         { confirmOrHighlight(route) },
                                                isFavorited:   favoriteRouteIDs.contains(route.id),
                                                toggleFavorite:{ toggleFavorite(route) }
                                            )
                                            .padding(.horizontal, 12)
                                        }
                                    }
                                }
                            }
                            .padding(.top, 12)
                        }

                        Spacer()
                    }
                    .padding(.top, 24)
                }

                // loading overlay
                if stopVM.isLoading {
                    Color.black.opacity(0.25).ignoresSafeArea()
                    ProgressView("Loading stops…")
                        .padding(16)
                        .background(.regularMaterial)
                        .cornerRadius(8)
                }

                // ─── CONFIRMATION OVERLAY ───────────────────
                if let stop = stopVM.selectedStop,
                   let rid = focusedRouteID,
                   let arrival = stopVM.arrivals.first(where: { $0.route == rid }) {
                    
                    // blur everything
                    VisualEffectBlur(blurStyle: .systemThinMaterialDark)
                        .ignoresSafeArea()
                        .zIndex(1)

                    // center card + cancel button
                    VStack(spacing: 16) {
                        // re-use your RouteCard in “selected” mode
                        let route = Route(
                            id:           arrival.route,
                            name:         "\(arrival.route)",
                            arrivalTime:  arrival.scheduled,
                            direction:    "",
                            realTime:     arrival.estimated ?? arrival.scheduled,
                            isMAX:        false
                        )
                        RouteCard(
                            parentStop:  stop,
                            line:        route,
                            isSelected:  true,
                            onTap:       { navigate(to: route) },
                            isFavorited: favoriteRouteIDs.contains(route.id),
                            toggleFavorite: {}
                        )
                        .padding()
                        .background(Color(.secondarySystemBackground).opacity(0.8))
                        .cornerRadius(12)
                        
                       // instructional text
                        Text("Tap the card again to continue, or Cancel below")
                          .font(.subheadline)
                          .foregroundColor(.white.opacity(0.8))
                          .multilineTextAlignment(.center)
                          .padding(.horizontal, 16)

                        Button("Cancel") {
                            focusedRouteID = nil
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 24)
                        .background(Color(.systemBackground))
                        .cornerRadius(8)
                    }
                    .zIndex(2)
                }
            }
            // errors & lifecycle
            .alert("Error loading stops", isPresented: $stopVM.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(stopVM.errorMessage ?? "Unknown")
            }
            .onAppear { stopVM.loadStops() }
            .onChange(of: stopVM.selectedStop) { newStop in
                if let s = newStop { stopVM.loadArrivals(for: s) }
                else { stopVM.arrivals = [] }
            }
        }
        // tell SwiftUI how to push a Route
        .navigationDestination(for: Route.self) { route in
            RouteDetailView(
                parentStop:  stopVM.selectedStop!,
                route:       route,
                navPath:     $navigationPath,
                timeManager: timeManager
            )
        }
    }

    // MARK: – Actions

    /// First tap highlights; second tap (on card) confirms
    private func confirmOrHighlight(_ route: Route) {
        if focusedRouteID == route.id {
            navigate(to: route)
        } else {
            focusedRouteID = route.id
        }
    }

    /// Actually navigate into detail
    private func navigate(to route: Route) {
        focusedRouteID = nil
        navigationPath.append(route)
        timeManager.startTimer()
    }

    private func toggleFavorite(_ route: Route) {
        if favoriteRouteIDs.contains(route.id) {
            favoriteRouteIDs.remove(route.id)
        } else {
            favoriteRouteIDs.insert(route.id)
        }
    }
}
