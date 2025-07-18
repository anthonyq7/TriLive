//
//  LocationManager.swift
//  TriLive
//
//  Created by Brian Maina on 7/3/25.
//

import SwiftUI
import UIKit
import Foundation
import CoreLocation

// observable object managing user location updates
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    private let manager = CLLocationManager()
    // underlying CLLocationManager instance
    
    @Published var location: CLLocationCoordinate2D?
    // current user coordinates
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    // MARK: – Public API for SettingsView to call:
    
    func startUpdatingLocation() {
        manager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        manager.stopUpdatingLocation()
    }
    
    // delegate callback whenever new location(s) are available
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first?.coordinate
    }
}
