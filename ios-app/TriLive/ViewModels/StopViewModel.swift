//
//  StopViewModel.swift
//  TriLive
//
//  Created by Brian Maina on 7/3/25.
//

import Foundation
import Combine

final class StopViewModel: ObservableObject {
    @Published var allStops: [Stop] = []
    @Published var filteredStops: [Stop] = []
    @Published var selectedStop: Stop?

    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showError: Bool = false
    
    @Published var arrivals: [Arrival] = []
    @Published var isLoadingArrivals = false
    @Published var showArrivalsError = false
    @Published var arrivalsErrorMessage: String?

    

    private let stopService: StopService

    init(service: StopService = .shared) {
        self.stopService = service
    }
    
    func loadArrivals(for stop: Stop) {
      isLoadingArrivals = true
      showArrivalsError = false

      ArrivalService.shared.fetchArrivals(for: stop.id) { [weak self] result in
        DispatchQueue.main.async {
          self?.isLoadingArrivals = false
          switch result {
          case .success(let arr): self?.arrivals = arr
          case .failure(let err):
            self?.arrivalsErrorMessage = err.localizedDescription
            self?.showArrivalsError = true
          }
        }
      }
    }

    func loadStops() {
        errorMessage = nil
        showError = false
        isLoading = true

        stopService.fetchStops { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let list):
                    self?.allStops = list
                    self?.filteredStops = list
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    self?.showError = true
                }
            }
        }
    }

    /// updates `filteredStops` as you type
    func filter(query: String) {
        guard !query.isEmpty else {
            filteredStops = allStops
            return
        }
        filteredStops = allStops.filter {
            $0.name.localizedCaseInsensitiveContains(query)
            || String($0.id).hasPrefix(query)
        }
    }
}
