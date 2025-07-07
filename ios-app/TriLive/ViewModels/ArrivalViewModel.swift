//
//  ArrivalViewModel.swift
//  TriLive
//
//  Created by Brian Maina on 7/7/25.
//


import Foundation
import Combine

final class ArrivalViewModel: ObservableObject {
    @Published var arrivals: [Arrival] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false

    func loadArrivals(for stopID: Int) {
        isLoading = true
        showError = false
        ArrivalService.shared.fetchArrivals(for: stopID) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let arr):
                    self.arrivals = arr
                case .failure(let err):
                    self.errorMessage = err.localizedDescription
                    self.showError = true
                }
            }
        }
    }

    func clear() {
        arrivals = []
    }
}
