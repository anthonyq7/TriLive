//
//  StationsViewModel.swift
//  TriLive
//
//  Created by Brian Maina on 7/3/25.


import Foundation
import Combine

//This lives in your ViewModels folder.
final class StationsViewModel: ObservableObject {
  @Published var stations:   [Station] = []
  @Published var isLoading    = false
  @Published var errorMessage: String?
  @Published var showError    = false

    // todo: inject service for easier testing
       private let stationService: StationService

       // initializer with dependency injection
       init(service: StationService = .shared) {
           stationService = service
       }

       // kick off the network fetch
       func loadStations() {
           // reset previous error state before new load
           errorMessage = nil
           showError = false
           // start loading indicator
           isLoading = true

           stationService.fetchStations { [weak self] result in
               DispatchQueue.main.async {
                   // stop loading indicator
                   self?.isLoading = false
                   switch result {
                   case .success(let list):
                       // update stations list on success
                       self?.stations = list
                   case .failure(let error):
                       // map error to user-friendly message
                       self?.errorMessage = error.localizedDescription
                       self?.showError = true
                   }
               }
           }
       }
   }
