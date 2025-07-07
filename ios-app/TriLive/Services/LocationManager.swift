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
    // underlying cllocationmanager instance
    
    @Published var location: CLLocationCoordinate2D?
    // current user coordinates
    
    override init() {
        super.init()
        manager.delegate = self
        // set self as delegate to receive updates
        
        manager.desiredAccuracy = kCLLocationAccuracyBest
        // request highest accuracy
        
        manager.requestWhenInUseAuthorization()
        // prompt user for permission when in use
        
        manager.startUpdatingLocation()
        // begin tracking location
    }
    
    // delegate callback whenever new location(s) are available
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first?.coordinate
        // publish the first (most recent) coordinate
    }
    
    // TODO: handle authorization changes and errors
}
