//
//  StationsMapView.swift
//  TriLive
//
//  Created by Brian Maina on 7/3/25.
//

import SwiftUI
import MapKit

struct StationsMapView: View {
    @ObservedObject var viewModel: StationsViewModel
    // view model providing station data
    
    let focusStation: Station
    // the station to center/highlight

    // state for the map’s region; declared here without default so we can init it
    @State private var region: MKCoordinateRegion

    // custom initializer to seed `region` based on `focusStation`
    init(viewModel: StationsViewModel, focusStation: Station) {
        self.viewModel = viewModel
        self.focusStation = focusStation

        // initialize the @State wrapper for region
        _region = State(initialValue:
            MKCoordinateRegion(
                center: CLLocationCoordinate2D(
                    latitude:  focusStation.latitude,
                    longitude: focusStation.longitude
                ),
                span: MKCoordinateSpan(
                    latitudeDelta:  0.01,
                    longitudeDelta: 0.01
                )
            )
        )
    }

    var body: some View {
        // map showing annotations for all stations
        Map(coordinateRegion: $region,
            annotationItems: viewModel.stations
        ) { st in
            MapMarker(
                coordinate: CLLocationCoordinate2D(
                    latitude:  st.latitude,
                    longitude: st.longitude
                ),
                // highlights the focus station in red, others in blue
                tint: (st.id == focusStation.id) ? .red : .blue
            )
        }
        .onReceive(viewModel.$stations) { _ in
        }
    }
}
