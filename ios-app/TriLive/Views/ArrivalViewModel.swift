//
//  ArrivalViewModel.swift
//  TriLive
//
//  Created by Brian Maina on 7/7/25.
//

// ArrivalsViewModel.swift
import Foundation

@MainActor
class ArrivalsViewModel: ObservableObject {
  @Published var arrivals:     [Arrival] = []
  @Published var isLoading     = false
  @Published var errorMessage: String?

  private let api = APIClient()
  private var timer: Timer?

  let stopId:  Int
  let routeId: Int

  init(stopId: Int, routeId: Int) {
    self.stopId  = stopId
    self.routeId = routeId
  }

  func loadArrivals() async {
    isLoading = true
    defer    { isLoading = false }

    do {
      let all = try await api.fetchArrivals(for: stopId)
      // if you only want this route:
      arrivals = all.filter { $0.routeId == routeId }
    } catch {
      errorMessage = "Couldn’t load arrivals: \(error)"
    }
  }

    func startPolling(interval: TimeInterval = 30) {
      //Don’t re-start if we already have a timer
      guard timer == nil else { return }

      // Kick off an initial load immediately
      Task { await loadArrivals() }

      // Schedule the repeating timer
      timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
        Task { await self?.loadArrivals() }
      }
    }

    func stopPolling() {
      timer?.invalidate()
      timer = nil
    }
  }
