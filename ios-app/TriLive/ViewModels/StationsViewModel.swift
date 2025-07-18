//
//  StationsViewModel.swift
//  TriLive
//
//  Created by Brian Maina on 7/3/25.

import Foundation

@MainActor
final class StationsViewModel: ObservableObject {
  @Published var stations:     [Stop] = []
  @Published var isLoading     = false
  @Published var errorMessage: String?

  private let api = APIClient()

  func loadStations() async {
    // creates flag set before network call
    isLoading = true
    defer    { isLoading = false }
    // creates flag reset after method exits

    do {
      // creates async fetch and assigns results
      stations = try await api.fetchStops()
    } catch {
      // creates error handling and message set
      errorMessage = error.localizedDescription
    }
  }
}



