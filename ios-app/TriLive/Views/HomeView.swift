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

    // search text & focus state
    @State private var searchQuery = ""
    @FocusState private var isSearchFocused: Bool

    // view model for stops, arrivals & routes
    @StateObject private var stopVM = StopViewModel()

    // to highlight a route before confirming navigation
    @State private var focusedRouteID: Int?

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                // background
                Color("AppBackground")
                    .ignoresSafeArea()

                // main content + overlays
                contentView
                loadingOverlay
                selectionOverlay
            }
            // loads stops once on appear
            .onAppear {
                Task { await stopVM.loadStops() }
            }
            // shows error if loading stops fails
            .alert("Error loading stops", isPresented: $stopVM.showError) {
                Button("OK", role: .cancel) { stopVM.showError = false }
            } message: {
                Text(stopVM.errorMessage ?? "Unknown")
            }
            // start/stop polling arrivals when selectedStop changes
            .onChange(of: stopVM.selectedStop) { newStop in
                handleStopChange(newStop)
            }
            // tap a Route → navigate into detail
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
    }

    // MARK: Content
    private var contentView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                ExtractedLogoAndWelcomeView()

                // search bar
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
                .onChange(of: searchQuery) { q in
                    stopVM.filter(q)
                }
                .zIndex(1)

                // once user picks a stop, show its route cards
                if let stop = stopVM.selectedStop {
                    LazyVStack(spacing: 12) {
                        ForEach(stopVM.routes) { route in
                            RouteCard(
                                parentStop:     stop,
                                line:           route,
                                isSelected:     focusedRouteID == route.routeId,
                                onTap:          { confirmOrHighlight(route) },
                                isFavorited:    favoriteRouteIDs.contains(route.routeId),
                                toggleFavorite: { toggleFavorite(route) }
                            )
                            .padding(.horizontal, 12)
                        }
                    }
                    .padding(.top, 12)
                }

                Spacer()
            }
            .padding(.top, 24)
        }
    }

    // MARK: Loading overlay
    @ViewBuilder
    private var loadingOverlay: some View {
        if stopVM.isLoading {
            Color.black.opacity(0.25).ignoresSafeArea()
            ProgressView("Loading stops…")
                .padding(16)
                .background(.regularMaterial)
                .cornerRadius(8)
        }
    }

    // MARK: Selection overlay (confirm route tap)
    @ViewBuilder
    private var selectionOverlay: some View {
        if let stop = stopVM.selectedStop,
           let rid  = focusedRouteID,
           let arrival = stopVM.arrivals.first(where: { $0.routeId == rid })
        {
            VisualEffectBlur(blurStyle: .systemThinMaterialDark)
                .ignoresSafeArea()
                .zIndex(1)

            VStack(spacing: 16) {
                let routeModel = Route(
                    stopId:     stop.id,
                    routeId:    arrival.routeId,
                    routeName:  arrival.routeName,
                    status:     arrival.status,
                    eta:        "\(arrival.minutesUntilArrival)",
                    routeColor: arrival.routeColor
                )
                RouteCard(
                    parentStop:     stop,
                    line:           routeModel,
                    isSelected:     true,
                    onTap:          { navigate(to: routeModel) },
                    isFavorited:    favoriteRouteIDs.contains(routeModel.routeId),
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

                Button("Cancel") { focusedRouteID = nil }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 24)
                    .background(Color(.systemBackground))
                    .cornerRadius(8)
            }
            .zIndex(2)
        }
    }

    // MARK: Helpers
    private func handleStopChange(_ newStop: Stop?) {
        if let s = newStop {
            stopVM.startPollingArrivals(for: s)
        } else {
            stopVM.stopPollingArrivals()
            stopVM.arrivals = []
            stopVM.routes   = []
        }
    }

    private func confirmOrHighlight(_ route: Route) {
        if focusedRouteID == route.routeId {
            navigate(to: route)
        } else {
            focusedRouteID = route.routeId
        }
    }

    private func navigate(to route: Route) {
        focusedRouteID = nil
        navigationPath.append(route)
        timeManager.startTimer()
    }

    private func toggleFavorite(_ route: Route) {
        if favoriteRouteIDs.contains(route.routeId) {
            favoriteRouteIDs.remove(route.routeId)
        } else {
            favoriteRouteIDs.insert(route.routeId)
        }
    }
}
