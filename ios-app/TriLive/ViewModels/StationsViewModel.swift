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
    isLoading = true
    defer    { isLoading = false }

    do {
      stations = try await api.fetchStops()
    } catch {
      errorMessage = error.localizedDescription
    }
  }
}



