// StopViewModel.swift

import Foundation
import Combine

@MainActor
final class StopViewModel: ObservableObject {
    // Stops
    @Published var allStops      : [Stop]  = []
    @Published var filteredStops : [Stop]  = []
    @Published var selectedStop  : Stop?
    
    // Arrivals & Routes
    @Published var arrivals            : [Arrival] = []
    @Published var routes              : [Route]   = []
    @Published var isLoadingArrivals   = false
    @Published var showArrivalsError   = false
    @Published var arrivalsErrorMessage: String?
    
    // Generic State
    @Published var isLoading   = false
    @Published var showError   = false
    @Published var errorMessage: String?
    
    private let api = APIClient()
    private var timer: AnyCancellable?
    
    func loadStops() async {
      isLoading      = true
      showError      = false
      errorMessage   = nil

      do {
        let stops = try await api.fetchStops()
        allStops       = stops
        filteredStops  = stops
      } catch {
        errorMessage = error.localizedDescription
        showError    = true
      }

      isLoading = false
    }

    //Filter the list of stops
    func filter(_ q: String) {
      if q.isEmpty {
        filteredStops = allStops
      } else {
        filteredStops = allStops.filter {
          $0.name.localizedCaseInsensitiveContains(q)
        }
      }
    }

    func loadArrivals(for stop: Stop) async {
      print(" Fetching arrivals for stopID = \(stop.id)")
      isLoadingArrivals = true
      showArrivalsError = false

      do {
        let raw = try await api.fetchArrivals(for: stop.id)
        print(" Raw arrivals JSON decoded: \(raw.count) items")

        // … collapse into earliestPerRoute / build routes …
        self.arrivals = raw
        let earliestPerRoute = Dictionary(grouping: raw, by: \.routeId)
          .compactMap { _, arrs in arrs.min(by: { $0.arrivalDate < $1.arrivalDate }) }

        self.routes = earliestPerRoute
          .sorted(by: { $0.arrivalDate < $1.arrivalDate })
          .map { a in
            Route(
              stopId:     stop.id,
              routeId:    a.routeId,
              routeName:  a.routeName,
              status:     a.status,
              eta:        "\(a.minutesUntilArrival)",
              routeColor: a.routeColor
            )
          }
          print("[DEBUG] routes.count = \(self.routes.count); ids = \(self.routes.map(\.routeId))")
        print(" routes built: \(self.routes.count)")
      } catch {
        print("loadArrivals error: \(error)")
        showArrivalsError = true
        arrivals = []
        routes   = []
      }

      isLoadingArrivals = false
    }
    
    func startPollingArrivals(for stop: Stop) {
        timer?.cancel()
        Task { await loadArrivals(for: stop) }
        timer = Timer
            .publish(every: 30, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task { await self?.loadArrivals(for: stop) }
            }
    }
    
    func stopPollingArrivals() {
        timer?.cancel()
        timer = nil
    }
}
