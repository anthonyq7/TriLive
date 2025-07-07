//
//  ContentView.swift
//  TriLive
//
//  Created by Anthony Qin on 6/6/25.
//

import SwiftUI
import CoreLocation

struct HomeView: View {
    // bound set of favorited route IDs from parent view
    @Binding var favoriteRouteIDs: Set<Int>
    // observed object providing location updates
    @ObservedObject var locationManager: LocationManager
    // observed object managing timing logic for routes
    @ObservedObject var timeManager: TimeManager
    // bound navigation path used by NavigationStack
    @Binding var navigationPath: NavigationPath
    @State private var searchQuery = ""
    // current search text for stops
    @FocusState private var isSearchFocused: Bool
    // tracks focus state of search field
    @StateObject private var stopVM = StopViewModel()
    // view model fetching & filtering stops
    @State private var focusedRoute: Route?
    // track a route on first tap

    var body: some View {
        NavigationStack(path: $navigationPath) {
            // navigation container
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // logo and welcome header
                        ExtractedLogoAndWelcomeView()

                        // search bar for entering stop names or IDs
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
                        .onChange(of: searchQuery) { stopVM.filter(query: $0) } // update filter on input
                        .zIndex(1)                                             // keep overlay on top

                        // display route cards for the selected stop
                        if let stop = stopVM.selectedStop {
                            ForEach(stop.routeList) { route in
                                RouteCard(
                                    parentStop:    stop,
                                    line:          route,
                                    isSelected:    (route.id == focusedRoute?.id),
                                    onTap:         { handleTap(route) },
                                    isFavorited:   favoriteRouteIDs.contains(route.id),
                                    toggleFavorite:{ toggleFavorite(route) }
                                )
                                .padding(.horizontal, 12)
                            }
                        }

                        Spacer()  // push content to top
                    }
                    .padding(.top, 24)  // spacing from top edge
                }
            }
            .onAppear { stopVM.loadStops() }
            // trigger loading when view appears
            .navigationDestination(for: Route.self) { route in
                // switch from guard…else+return to an if-let inside the ViewBuilder
                if let stop = stopVM.allStops.first(where: { $0.routeList.contains(where: { $0.id == route.id }) }) {
                    // this view will be emitted when we find the stop
                    RouteDetailView(
                        parentStop:  stop,
                        route:       route,
                        navPath:     $navigationPath,
                        timeManager: timeManager
                    )
                } else {
                    // fallback if no matching stop found
                    EmptyView()
                }
            }
        }
    }

    // first tap highlights the route, second tap navigates and starts the timer
    private func handleTap(_ route: Route) {
        if focusedRoute == nil {
            focusedRoute = route
        } else {
            navigationPath.append(route)
            timeManager.startTime()
            focusedRoute = nil
        }
    }

    // toggle favorite status for a route
    private func toggleFavorite(_ route: Route) {
        if favoriteRouteIDs.contains(route.id) {
            favoriteRouteIDs.remove(route.id)
        } else {
            favoriteRouteIDs.insert(route.id)
        }
    }
}

