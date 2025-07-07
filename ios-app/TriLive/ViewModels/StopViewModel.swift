//
//  StopViewModel.swift
//  TriLive
//
//  Created by Brian Maina on 7/3/25.
//

import Foundation
import Combine

final class StopViewModel: ObservableObject {
  @Published var allStops:    [Stop] = []
  @Published var filteredStops:[Stop] = []
  @Published var selectedStop: Stop?

    private let stopService: StopService
    // use dependency injection for easier testing

    init(service: StopService = .shared) {
        stopService = service
    }

    // kick off network fetch for stops
    func loadStops() {
        stopService.fetchStops { [weak self] result in
            // use StopService, not StationService
            DispatchQueue.main.async {
                // ensure UI updates on the main thread
                switch result {
                case .success(let list):
                    self?.allStops = list
                    // populates allStops
                    self?.filteredStops = list
                    // resets filteredStops
                case .failure(let err):
                    // TODO: update UI with an error state instead of printing
                    print("could not load stops:", err)
                }
            }
        }
    }

    // updates `filteredStops` as you type
    func filter(query: String) {
        guard !query.isEmpty else {
            filteredStops = allStops
            // if the query is empty, show all stops again
            return
        }
        filteredStops = allStops.filter {
            $0.name.localizedCaseInsensitiveContains(query)
            || String($0.id).hasPrefix(query)
        }
    }
}



