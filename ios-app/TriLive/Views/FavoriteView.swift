// FavoritesView.swift
// TriLive
import SwiftUI

struct FavoritesView: View {
    @Binding var favoriteRouteIDs: Set<Int>
    @Binding var selectedStop: Stop?
    @Binding var navPath:         NavigationPath
    @ObservedObject var timeManager: TimeManager
    @StateObject var stopVM = StopViewModel()
    
    // highlight/confirm tap state
    @State private var focusedRouteID: Int?

    // only show arrivals for routes the user has starred
    private var favoriteArrivals: [Arrival] {
        stopVM.arrivals.filter { favoriteRouteIDs.contains($0.routeId) }
    }

    var body: some View {
        NavigationStack(path: $navPath) {
            ZStack {
                Color("AppBackground").ignoresSafeArea()
                content
                selectionOverlay
            }
            .navigationTitle("Favorites")
            .onAppear {
                if let s = stopVM.selectedStop {
                    stopVM.startPollingArrivals(for: s)
                }
            }
            .onDisappear {
                stopVM.stopPollingArrivals()
            }
            .navigationDestination(for: Route.self) { route in
                if let parent = stopVM.selectedStop {
                    RouteDetailView(
                        parentStop:  parent,
                        route:       route,
                        stopVM:      stopVM,
                        navPath:     $navPath,
                        timeManager: timeManager
                    )
                }
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        if favoriteArrivals.isEmpty {
            Text("No Favorites Yet…")
                .font(.title2).fontWeight(.semibold)
                .padding(.top, 100)
        } else {
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 12) {
                    ForEach(favoriteArrivals, id: \.routeId) { arrival in
                        // build a Route model for this arrival
                        let routeModel = Route(
                            stopId:     stopVM.selectedStop?.id ?? 0,
                            routeId:    arrival.routeId,
                            routeName:  arrival.routeName,
                            status:     arrival.status,
                            eta:        "\(arrival.minutesUntilArrival)",
                            routeColor: arrival.routeColor,
                            eta_unix:   arrival.eta
                        )

                        RouteCard(
                            parentStop:    stopVM.selectedStop!,
                            line:          routeModel,
                            isSelected:    focusedRouteID == routeModel.routeId,
                            isFavorited:   true,
                            onTap:         { confirmOrHighlight(routeModel) },
                            onFavoriteTapped: {
                                // remove from favorites only when ⭐︎ tapped
                                favoriteRouteIDs.remove(routeModel.routeId)
                            }
                        )
                        .padding(.horizontal, 12)
                    }
                }
                .padding(.vertical, 16)
            }
        }
    }

    @ViewBuilder
    private var selectionOverlay: some View {
        if let stop    = stopVM.selectedStop,
           let rid     = focusedRouteID,
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
                    routeColor: arrival.routeColor,
                    eta_unix:   arrival.eta
                )

                RouteCard(
                    parentStop:    stop,
                    line:          routeModel,
                    isSelected:    true,
                    isFavorited:   true,
                    onTap:         { navigate(to: routeModel) },
                    onFavoriteTapped: {
                        favoriteRouteIDs.remove(routeModel.routeId)
                    }
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


    private func confirmOrHighlight(_ route: Route) {
        if focusedRouteID == route.routeId {
            navigate(to: route)
        } else {
            focusedRouteID = route.routeId
        }
    }

    private func navigate(to route: Route) {
        focusedRouteID = nil
        navPath.append(route)
        timeManager.startTimer()
    }
}
