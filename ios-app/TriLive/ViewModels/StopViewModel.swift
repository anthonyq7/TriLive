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
    private var hasLoadedStops = false
    
    func loadStops() async {
          // bail out if we’ve already done this once
          guard !hasLoadedStops else { return }
          hasLoadedStops = true

          isLoading     = true
          showError     = false
          errorMessage  = nil

          do {
            let stops = try await api.fetchStops()
            allStops      = stops
            filteredStops = stops
          } catch {
            errorMessage = error.localizedDescription
            showError    = true
          }

          isLoading = false
        }
    
    //Filter the list of stops
    func filter(_ q: String) {
        let raw = q
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        
        guard !raw.isEmpty else {
            filteredStops = allStops
            return
        }
        
        let alt1 = raw.replacingOccurrences(of: "&",   with: "and")
        let alt2 = raw.replacingOccurrences(of: "and", with: "&")
        let queries = Set([raw, alt1, alt2])
        
        filteredStops = allStops.filter { stop in
            let nameLower = (stop.name + " " + (stop.dir ?? "")).lowercased()
            let idLower   = String(stop.id).lowercased()
            
            let nameMatches = queries.contains { nameLower.contains($0) }
            let idMatches   = queries.contains { idLower.contains($0) }
            
            return nameMatches || idMatches
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
                        routeColor: a.routeColor,
                        eta_unix: a.eta
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
            .publish(every: 15, on: .main, in: .common)
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
