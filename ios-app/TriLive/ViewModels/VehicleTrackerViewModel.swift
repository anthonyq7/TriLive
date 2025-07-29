//
//  VehicleTrackerViewModel.swift
//  TriLive
//
//  Created by Anthony Qin on 7/28/25.
//

import Foundation
import Combine
import CoreLocation

@MainActor
final class VehicleTrackerViewModel: ObservableObject {
    @Published var positions: [CLLocationCoordinate2D] = []
    @Published var currentPosition: CLLocationCoordinate2D?

    private let api = APIClient()
    private let stopId: Int
    private let routeId: Int
    private let vehicleId: Int
    private var timer: AnyCancellable?

    init(stopId: Int, routeId: Int, vehicleId: Int) {
        self.stopId = stopId
        self.routeId = routeId
        self.vehicleId = vehicleId
    }

    func startTracking() {
        timer?.cancel()
        fetchPosition()
        timer = Timer.publish(every: 5, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.fetchPosition() }
    }

    func stopTracking() {
        timer?.cancel()
        timer = nil
    }

    private func fetchPosition() {
        Task {
            do {
                let vehiclePositions = try await api.fetchVehiclePositions(for: stopId, routeId: routeId, vehicleId: vehicleId)
                if let last = vehiclePositions.last {
                    let coord = CLLocationCoordinate2D(latitude: last.lat, longitude: last.lng)
                    positions.append(coord)
                    currentPosition = coord
                }
            } catch {
                print("VehicleTracker error: \(error)")
            }
        }
    }
}
