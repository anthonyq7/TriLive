//
//  HomeView.swift
//  TriLive
//
//  Created by Anthony Qin on 6/6/25.
//

import SwiftUI
import CoreLocation

struct HomeView: View {
    // MARK: – Injected
    @ObservedObject var favoritesManager: FavoritesManager
    @ObservedObject var stopVM:            StopViewModel
    @ObservedObject var timeManager:       TimeManager
    @ObservedObject var locationManager:   LocationManager
    @Binding       var navigationPath:     NavigationPath
    @Binding var favoriteRouteIDs: Set<Int>

    
    // MARK: – Local
    @State private var searchQuery       = ""
    @FocusState private var isSearchFocused: Bool
    @State private var focusedRoute: Route?
    
    var body: some View {
        ZStack {
            Color("AppBackground")
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    ExtractedLogoAndWelcomeView()
                    
                    // Your original SearchBar
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
                    
                    // Only show when a stop is chosen
                    if let stop = stopVM.selectedStop {
                        VStack(alignment: .leading, spacing: 16) {
                            Text(stop.name)
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                            
                            LazyVStack(spacing: 12) {
                                ForEach(stopVM.routes) { route in
                                    RouteCard(
                                        parentStop:  stop,
                                        line:        route,
                                        isSelected:  focusedRoute == route,
                                        isFavorited: favoriteRouteIDs.contains(route.routeId),
                                        onTap:       { confirmOrHighlight(route) },
                                        onFavoriteTapped: { toggleFavorite(route) }
                                    )
                                    .padding(.horizontal, 12)
                                }
                            }
                            .animation(.easeIn, value: stopVM.routes)
                            .padding(.bottom, 24)
                        }
                    }
                    
                    Spacer(minLength: 50)
                }
                .padding(.top, 24)
            }
            
            // MARK: – Confirm overlay
            selectionOverlay
        }
        // MARK: – Lifecyle & bindings
        
        // Load stops once
        .onAppear { Task { await stopVM.loadStops() } }
        
        // Dismiss keyboard
        .onTapGesture { isSearchFocused = false }
        
        // Poll / clear when selectedStop changes
        .onChange(of: stopVM.selectedStop) { newStop in
            if let s = newStop {
                stopVM.startPollingArrivals(for: s)
            } else {
                stopVM.stopPollingArrivals()
                stopVM.arrivals = []
                stopVM.routes   = []
            }
            // also clear any half-tapped overlay
            focusedRoute = nil
        }
        
        // Error alert on loadStops
        .alert("Error loading stops", isPresented: $stopVM.showError) {
            Button("OK", role: .cancel) { stopVM.showError = false }
        } message: {
            Text(stopVM.errorMessage ?? "Unknown")
        }
        
        // Navigation on confirm
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
    
    // MARK: – Overlay builder
    @ViewBuilder
    private var selectionOverlay: some View {
        if let stop = stopVM.selectedStop,
           let r  = focusedRoute,
           let arrival = stopVM.arrivals.first(where: { $0.routeId == r.id && $0.eta == r.eta_unix}) {
            
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
                //.background(Color(.secondarySystemBackground).opacity(0.8))
                .cornerRadius(12)
                
                Text("Tap again to confirm, or Cancel below")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                
                Button("Cancel") {
                    focusedRoute = nil
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 24)
                .background(Color(.systemBackground))
                .cornerRadius(8)
            }
            .zIndex(2)
        }
    }
    
    // MARK: – Helpers
    private func confirmOrHighlight(_ route: Route) {
        if focusedRoute == route{
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

struct HomeView_Previews: PreviewProvider {
  static var previews: some View {
    // create one instance of each dependency
    let favs    = FavoritesManager()
    let stops   = StopViewModel()
    let times   = TimeManager()
    let locs    = LocationManager()
    let path    = Binding.constant(NavigationPath())

      HomeView(
        favoritesManager: favs,
        stopVM:           stops,
        timeManager:      times,
        locationManager:  locs,
        navigationPath:   path,
        favoriteRouteIDs: .constant([])   // ← add this!
      )
    .preferredColorScheme(.dark)
  }
}
