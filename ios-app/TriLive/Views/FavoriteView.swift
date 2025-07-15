import SwiftUI

struct FavoritesView: View {
    @Binding var favoriteRouteIDs: Set<Int>
    @Binding var navPath: NavigationPath
    @ObservedObject var timeManager: TimeManager

    @StateObject private var stopVM = StopViewModel()

    //filter only the arrivals you care about
    private var favoriteArrivals: [Arrival] {
        stopVM.arrivals.filter { favoriteRouteIDs.contains($0.routeId) }
    }

    private var favoritesList: some View {
        Group {
            if favoriteArrivals.isEmpty {
                Text("No Favorites Yet…")
                    .font(.title2).fontWeight(.semibold)
                    .padding(.horizontal, 16)
            } else {
                Text("Your Favorites")
                    .font(.title2).fontWeight(.semibold)
                    .padding(.horizontal, 16)

                LazyVStack(spacing: 12) {
                    ForEach(favoriteArrivals, id: \.id) { arrival in
                        favoriteRow(for: arrival)
                    }
                }
                .padding(.top, 8)
            }
        }
    }

    private func favoriteRow(for arrival: Arrival) -> some View {
        // build the Route model outside the gesture
        let routeModel = Route(
            stopId:     stopVM.selectedStop?.id ?? 0,
            routeId:    arrival.routeId,
            routeName:  arrival.routeName,
            status:     arrival.status,
            eta:        "\(arrival.minutesUntilArrival)",
            routeColor: arrival.routeColor
        )

        return HStack {
            Text(arrival.routeName)
            Spacer()
            Text(DateFormatter.localizedString(
                from: arrival.arrivalDate,
                dateStyle: .none,
                timeStyle: .short
            ))
        }
        .foregroundColor(.white)
        .padding(.horizontal)
        .contentShape(Rectangle())
        .onTapGesture {
            navPath.append(routeModel)
            timeManager.startTimer()
        }
    }

    var body: some View {
        NavigationStack(path: $navPath) {
            ZStack {
                Color("AppBackground").ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        favoritesList
                            .padding(.vertical)
                    }
                }
            }
            .navigationDestination(for: Route.self) { route in
                if let stop = stopVM.selectedStop {
                    RouteDetailView(
                        parentStop:  stop,
                        route:       route,
                        stopVM:      stopVM,
                        navPath:     $navPath,
                        timeManager: timeManager
                    )
                }
            }
            .onAppear {
                if let stop = stopVM.selectedStop {
                    stopVM.startPollingArrivals(for: stop)
                }
            }
            .onDisappear {
                stopVM.stopPollingArrivals()
            }
        }
    }
}
