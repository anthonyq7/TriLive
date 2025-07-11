import SwiftUI

struct FavoritesView: View {
  @Binding var favoriteRouteIDs: Set<Int>
  @Binding var navPath: NavigationPath
  @ObservedObject var timeManager: TimeManager

  @StateObject private var stopVM = StopViewModel()

  private var favoriteArrivals: [Arrival] {
    stopVM.arrivals.filter { favoriteRouteIDs.contains($0.route) }
  }

  var body: some View {
    NavigationStack(path: $navPath) {
      ZStack {
        Color.appBackground.ignoresSafeArea()

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
                ForEach(favoriteArrivals, id: \.id) { arrival in
                  HStack {
                    Text("Route \(arrival.route)")
                    Spacer()
                    let date = Date(timeIntervalSince1970: TimeInterval(arrival.scheduled) / 1000)
                    Text(
                      DateFormatter.localizedString(
                        from: date,
                        dateStyle: .none,
                        timeStyle: .short
                      )
                    )
                  }
                  .foregroundColor(.white)
                  .padding(.horizontal)
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
            parentStop:  stop,
            route:       route,
            navPath:     $navPath,
            timeManager: timeManager
          )
        } else {
          EmptyView()
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
