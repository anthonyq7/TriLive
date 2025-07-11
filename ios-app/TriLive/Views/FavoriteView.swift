//
//  FavoriteView.swift
//  TriLive
//
//  Created by Brian Maina on 6/22/25.
//

//
//  FavoritesView.swift
//  TriLive
//
//  Created by <you> on <date>.
//

import SwiftUI

struct FavoritesView: View {
    // same bindings you already have
    @Binding var favoriteRouteIDs: Set<Int>
    @Binding var navPath: NavigationPath
    @ObservedObject var timeManager: TimeManager

    // observe the same view model you use in HomeView
    @StateObject private var stopVM = StopViewModel()

    // compute only the arrivals you’ve favorited
    private var favoriteArrivals: [Arrival] {
        stopVM.arrivals.filter { favoriteRouteIDs.contains($0.route) }
    }

    var body: some View {
        NavigationStack(path: $navPath) {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        if favoriteArrivals.isEmpty {
                            Text("No Favorites Yet…")
                                .font(.title2).fontWeight(.semibold)
                                .padding(.horizontal, 16)
                        } else {
                            Text("Your Favorites")
                                .font(.title2).fontWeight(.semibold)
                                .padding(.horizontal, 16)

                            LazyVStack(spacing: 12) {
                                ForEach(favoriteArrivals) { arrival in
                                    // map Arrival → Route so you can reuse RouteCard
                                    let route = Route(
                                          id:          arrival.route,
                                          name:        "\(arrival.route)",
                                          arrivalTime: arrival.scheduled,
                                          direction:   "",
                                          realTime:    arrival.estimated ?? arrival.scheduled,
                                          isMAX:       false
                        
                                    )

                                    // only show if we have a selectedStop context
                                    if let stop = stopVM.selectedStop {
                                        NavigationLink(value: route) {
                                            FavoriteCard(
                                                parentStop: stop,
                                                route:      route,
                                                onRemove:   { favoriteRouteIDs.remove(route.id) }
                                            )
                                            .padding(.horizontal)
                                        }
                                    }
                                }
                            }
                            .padding(.top, 8)
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationDestination(for: Route.self) { route in
                if let stop = stopVM.selectedStop {
                    RouteDetailView(
                        parentStop: stop,
                        route:      route,
                        navPath:    $navPath,
                        timeManager: timeManager,
                    )
                    
                } else {
                    EmptyView()
                }
            }

        }
    }
}
