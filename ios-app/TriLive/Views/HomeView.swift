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

    // view model for stops & arrivals
    @StateObject private var stopVM = StopViewModel()

    // to highlight a route before confirming navigation
    @State private var focusedRouteID: Int?

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                backgroundView
                contentView
                loadingOverlay
                selectionOverlay
            }
            .alert("Error loading stops", isPresented: $stopVM.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(stopVM.errorMessage ?? "Unknown")
            }
            .onAppear { stopVM.loadStops() }
            .onChange(of: stopVM.selectedStop, perform: handleStopChange)
        }
        .navigationDestination(for: Route.self) { route in
            RouteDetailView(
                parentStop:  stopVM.selectedStop!,
                route:       route,
                stopVM:      stopVM,       
                navPath:     $navigationPath,
                timeManager: timeManager
            )
        }
    }

    // MARK: – Background

    private var backgroundView: some View {
        Color("AppBackground")
            .ignoresSafeArea()
    }

    // MARK: – Main Content

    private var contentView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // your custom logo + welcome
                ExtractedLogoAndWelcomeView()

                searchBar

                if let stop = stopVM.selectedStop {
                    arrivalsSection(for: stop)
                }

                Spacer()
            }
            .padding(.top, 24)
        }
    }

    private var searchBar: some View {
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
    }

    @ViewBuilder
    private func arrivalsSection(for stop: Stop) -> some View {
        Group {
            if stopVM.isLoadingArrivals {
                ProgressView("Loading arrivals…")
            } else if stopVM.showArrivalsError {
                Text("Error: \(stopVM.arrivalsErrorMessage ?? "Unknown")")
                    .foregroundColor(.red)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(stopVM.arrivals, id: \.id) { arrival in
                        let route = Route(
                            id:           arrival.route,
                            name:         "Route \(arrival.route)",
                            arrivalTime:  arrival.scheduled,
                            direction:    "",
                            realTime:     arrival.estimated ?? arrival.scheduled,
                            isMAX:        false
                          )
                        RouteCard(
                              parentStop:   stop,
                              line:         route,
                              isSelected:   focusedRouteID == route.id,
                              onTap:        { confirmOrHighlight(route) },
                              isFavorited:  favoriteRouteIDs.contains(route.id),
                              toggleFavorite: { toggleFavorite(route) }
                            )
                            .padding(.horizontal, 12)
                    }
                }
            }
        }
        .padding(.top, 12)
    }


    // MARK: – Loading Overlay

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

    //Selection Overlay

    @ViewBuilder
    private var selectionOverlay: some View {
        if let stop = stopVM.selectedStop,
           let rid = focusedRouteID,
           let arrival = stopVM.arrivals.first(where: { $0.route == rid }) {

            VisualEffectBlur(blurStyle: .systemThinMaterialDark)
                .ignoresSafeArea()
                .zIndex(1)

            VStack(spacing: 16) {
                let route = Route(
                    id:           arrival.route,
                    name:         "\(arrival.route)",        // or “Route \(arrival.route)”
                    arrivalTime:  arrival.scheduled,
                    direction:    "",                         // you can hard-code or compute this if you want
                    realTime:     arrival.estimated ?? arrival.scheduled,
                    isMAX:        false                       // pick your default
                )
                RouteCard(
                    parentStop:   stop,
                    line:         route,
                    isSelected:   true,
                    onTap:        { navigate(to: route) },
                    isFavorited:  favoriteRouteIDs.contains(route.id),
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

    // MARK: – Actions & Helpers

    private func handleStopChange(_ newStop: Stop?) {
        if let s = newStop {
            stopVM.startPollingArrivals(for: s, every: 30)
        } else {
            stopVM.stopPollingArrivals()
            stopVM.arrivals = []
        }
    }

    private func confirmOrHighlight(_ route: Route) {
        if focusedRouteID == route.id {
            navigate(to: route)
        } else {
            focusedRouteID = route.id
        }
    }

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
