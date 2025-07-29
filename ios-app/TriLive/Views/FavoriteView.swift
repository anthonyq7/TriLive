//
//  FavoritesView.swift
//  TriLive
//
//  Created by Brian Maina on 7/3/25.
//

import SwiftUI

struct FavoritesView: View {
    // MARK: – Injected dependencies
    @ObservedObject var favoritesManager: FavoritesManager
    @ObservedObject var stopVM:            StopViewModel
    @ObservedObject var timeManager:       TimeManager
    @Binding       var navigationPath:     NavigationPath

    // MARK: – Local state for tap-to-confirm overlay
    @State private var focusedRouteID: Int?

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                // full-screen grey background
                Color("AppBackground")
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // For each stopId in our grouped, vetted favorites
                        ForEach(groupedRoutes.keys.sorted(), id: \.self) { stopId in
                            // header
                            Text(stopName(for: stopId).uppercased())
                                .font(.caption.weight(.semibold))
                                .foregroundColor(.gray)
                                .padding(.horizontal, 16)

                            VStack(spacing: 8) {
                                // routes for that stop, sorted by routeId
                                ForEach(groupedRoutes[stopId]!.sorted(by: { $0.routeId < $1.routeId }), id: \.routeId) { route in
                                    // safely unwrap the parent Stop
                                    if let parent = parentStop(for: route) {
                                        RouteCard(
                                            parentStop:  parent,
                                            line:        route,
                                            isSelected:  focusedRouteID == route.routeId,
                                            isFavorited: true,
                                            onTap:       { confirmOrHighlight(route) },
                                            onFavoriteTapped: {
                                                favoritesManager.toggle(route)
                                            }
                                        )
                                        .padding(.vertical, 6)
                                        .padding(.horizontal, 12)
                                        .background(Color("CardBackground"))
                                        .cornerRadius(10)
                                    }
                                }
                            }
                            .padding(.horizontal, 4)
                        }
                    }
                    .padding(.vertical, 16)
                }

                // overlay on top when confirming
                selectionOverlay
            }
            .navigationTitle("Favorites")
            // no polling here—we leave stopVM to Home
            .navigationDestination(for: Route.self) { route in
                // safely unwrap before navigating
                if let parent = parentStop(for: route) {
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

    // MARK: – confirm overlay builder

    @ViewBuilder
    private var selectionOverlay: some View {
        if let rid = focusedRouteID,
            let route = favoritesManager.routes.first(where: { $0.routeId == rid }),
            let parent = parentStop(for: route),
            let arrival = stopVM.arrivals.first(where: { $0.routeId == rid })
        {
            VisualEffectBlur(blurStyle: .systemThinMaterialDark)
                .ignoresSafeArea()
                .zIndex(1)

            VStack(spacing: 16) {
                let model = Route(
                    stopId:     parent.id,
                    routeId:    arrival.routeId,
                    routeName:  arrival.routeName,
                    status:     arrival.status,
                    eta:        "\(arrival.minutesUntilArrival)",
                    routeColor: arrival.routeColor,
                    eta_unix:   arrival.eta,
                    vehicleId: arrival.vehicleId
                )

                RouteCard(
                    parentStop:    parent,
                    line:          model,
                    isSelected:    true,
                    isFavorited:   true,
                    onTap:         { navigate(to: model) },
                    onFavoriteTapped: {
                        favoritesManager.toggle(model)
                        focusedRouteID = nil
                    }
                )
                .padding()
                .background(Color(.secondarySystemBackground).opacity(0.8))
                .cornerRadius(12)

                Text("Tap again to confirm, or Cancel below")
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

    //Helpers

    /// Only group favorites for stops we actually have loaded
    private var groupedRoutes: [Int: [Route]] {
        let valid = favoritesManager.routes.filter { fav in
            stopVM.allStops.contains(where: { $0.id == fav.stopId })
        }
        return Dictionary(grouping: valid, by: \.stopId)
    }

    /// Human-readable stop name, or fallback
    private func stopName(for stopId: Int) -> String {
        stopVM.allStops.first(where: { $0.id == stopId })?.name
        ?? "Stop \(stopId)"
    }

    /// Safely look up the Stop for a given Route
    private func parentStop(for route: Route) -> Stop? {
        stopVM.allStops.first(where: { $0.id == route.stopId })
    }

    /// Tap once to highlight (for overlay), tap again to navigate
    private func confirmOrHighlight(_ route: Route) {
        if focusedRouteID == route.routeId {
            navigate(to: route)
        } else {
            focusedRouteID = route.routeId
        }
    }

    /// Navigate to detail view
    private func navigate(to route: Route) {
        focusedRouteID = nil
        navigationPath.append(route)
        timeManager.startTimer()
    }
}

// MARK: – Preview

struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesView(
            favoritesManager: FavoritesManager(),
            stopVM:            StopViewModel(),
            timeManager:       TimeManager(),
            navigationPath:    .constant(NavigationPath())
        )
        .preferredColorScheme(.dark)
    }
}

