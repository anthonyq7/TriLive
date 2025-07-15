import SwiftUI
import MapKit

struct StationsMapView: View {
    @ObservedObject var viewModel: StationsViewModel
    let focusStation: Stop

    @State private var region: MKCoordinateRegion

    init(viewModel: StationsViewModel, focusStation: Stop) {
        self.viewModel    = viewModel
        self.focusStation = focusStation

        // Initialize sthe map region centered on our focus stop
        _region = State(initialValue:
            MKCoordinateRegion(
                center: CLLocationCoordinate2D(
                    latitude:  focusStation.lat,
                    longitude: focusStation.lon
                ),
                span: MKCoordinateSpan(
                    latitudeDelta:  0.01,
                    longitudeDelta: 0.01
                )
            )
        )
    }

    var body: some View {
        Map(
            coordinateRegion: $region,
            annotationItems: viewModel.stations
        ) { stop in
            MapMarker(
                coordinate: CLLocationCoordinate2D(
                    latitude:  stop.lat,
                    longitude: stop.lon
                ),
                // highlights the focused stop in red
                tint: (stop.id == focusStation.id) ? .red : .blue
            )
        }
        .onReceive(viewModel.$stations) { _ in
        }
        .onAppear {
            // ensures we load the stops when this map appears
            Task {
                await viewModel.loadStations()
            }
        }
    }
}
