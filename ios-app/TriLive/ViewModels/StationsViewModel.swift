//
//  StationsViewModel.swift
//  TriLive
//
//  Created by Brian Maina on 7/3/25.


import Foundation
import Combine

//This lives in your ViewModels folder.
final class StationsViewModel: ObservableObject {
    @Published var stations: [Station] = []

    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false

    func loadStations() {
        errorMessage = nil
        showError = false
        isLoading = true

        StationService.shared.fetchStations { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let list):
                    self?.stations = list
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    self?.showError = true
                }
            }
        }
    }
}
