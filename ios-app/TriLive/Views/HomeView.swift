// HomeView.swift
// TriLive

import SwiftUI
import CoreLocation

struct HomeView: View {
    // injected from App entry-point
    @Binding var favoriteRouteIDs: Set<Int>
    @ObservedObject var locationManager: LocationManager
    @ObservedObject var timeManager: TimeManager
    @Binding var navigationPath: NavigationPath

    // this tracks whether a stop has been chosen
    @State private var stopSelected = false

    // search text & focus state
    @State private var searchQuery = ""
    @FocusState private var isSearchFocused: Bool

    // view model for stops & arrivals
    @StateObject private var stopVM = StopViewModel()

    // to highlight a route before confirming navigation
    @State private var focusedRouteID: Int?

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                Color("AppBackground")
                    .ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // your custom logo + welcome
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
                                            // convert Arrival to Route for display
                                            let route = Route(
                                                id:           arrival.route,
                                                name:         arrival.name,
                                                arrivalTime:  arrival.scheduled,
                                                direction:    arrival.direction,
                                                realTime:     arrival.estimated ?? arrival.scheduled,
                                                isMAX:        arrival.isMAX
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

                if stopVM.isLoading {
                    Color.black.opacity(0.25).ignoresSafeArea()
                    ProgressView("Loading stops…")
                        .padding(16)
                        .background(.regularMaterial)
                        .cornerRadius(8)
                }

                if let stop = stopVM.selectedStop,
                   let rid = focusedRouteID,
                   let arrival = stopVM.arrivals.first(where: { $0.route == rid }) {

                    VisualEffectBlur(blurStyle: .systemThinMaterialDark)
                        .ignoresSafeArea()
                        .zIndex(1)

                    VStack(spacing: 16) {
                        let route = Route(
                            id:           arrival.route,
                            name:         arrival.name,
                            arrivalTime:  arrival.scheduled,
                            direction:    arrival.direction,
                            realTime:     arrival.estimated ?? arrival.scheduled,
                            isMAX:        arrival.isMAX
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
            .alert("Error loading stops", isPresented: $stopVM.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(stopVM.errorMessage ?? "Unknown")
            }
            .onAppear { stopVM.loadStops() }
            .onChange(of: stopVM.selectedStop) { newStop in
                if let s = newStop {
                    // user picked a stop then start polling every 30s
                    stopVM.startPollingArrivals(for: s, every: 30)
                } else {
                    // no stop selected then stop polling and clear
                    stopVM.stopPollingArrivals()
                    stopVM.arrivals = []
                }
            }
            .onAppear {
                stopVM.loadStops()
            }
        }
        .navigationDestination(for: Route.self) { route in
            RouteDetailView(
                parentStop:  stopVM.selectedStop!,
                route:       route,
                navPath:     $navigationPath,
                timeManager: timeManager,
                stopVM: stopVM
            )
        }
    }

    // MARK: – Actions
    //First tap highlights; second tap confirms navigation
    private func confirmOrHighlight(_ route: Route) {
        if focusedRouteID == route.id {
            navigate(to: route)
        } else {
            focusedRouteID = route.id
        }
    }

    //Perform the actual navigation and start timing
    private func navigate(to route: Route) {
        focusedRouteID = nil
        navigationPath.append(route)
        timeManager.startTimer()
    }

    //Toggle favorite state
    private func toggleFavorite(_ route: Route) {
        if favoriteRouteIDs.contains(route.id) {
            favoriteRouteIDs.remove(route.id)
        } else {
            favoriteRouteIDs.insert(route.id)
        }
    }
}
