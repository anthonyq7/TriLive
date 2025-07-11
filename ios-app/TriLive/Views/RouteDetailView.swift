// RouteDetailView.swift

import SwiftUI
import MapKit

struct RouteDetailView: View {
    let parentStop: Stop
    let route:       Route

    @ObservedObject var stopVM:    StopViewModel
    @Binding        var navPath:   NavigationPath
    @ObservedObject var timeManager: TimeManager

    @State private var isLiveActive = true
    @StateObject private var stationVM   = StationsViewModel()

    var body: some View {
        ZStack {
            Color("AppBackground")
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // MARK: Header
                    HStack(spacing: 16) {
                        Circle()
                            .fill(route.isMAX ? Color.blue : Color.green)
                            .frame(width: 48, height: 48)
                            .overlay(
                                Text(route.isMAX ? "MAX" : "\(route.id)")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            )

                        VStack(alignment: .leading, spacing: 2) {
                            Text(route.name)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)

                            Text("Stop: \(parentStop.name)")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))
                        }

                        Spacer()
                    }
                    .padding()
                    .background(Color("AppBackground").opacity(0.5))
                    .cornerRadius(16)
                    .padding(.horizontal)

                    // Stop Button
                    Button("Stop") {
                        isLiveActive = false
                        navPath.removeLast()
                        stopVM.stopPollingArrivals()
                        timeManager.stopTimer()
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: 300)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(25)
                    .padding(.horizontal)

                    // Live Activity
                    if isLiveActive {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Live Activity")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)

                            if stopVM.isLoadingArrivals {
                                ProgressView()
                                    .foregroundColor(.white)
                            }
                            else if stopVM.showArrivalsError {
                                Text(stopVM.arrivalsErrorMessage ?? "Failed to load")
                                    .foregroundColor(.red)
                            }
                            else {
                                ForEach(stopVM.arrivals) { a in
                                    HStack {
                                        Text("Route \(a.route)")
                                        Spacer()
                                        Text(DateFormatter.localizedString(
                                            from: a.scheduledDate,
                                            dateStyle: .none,
                                            timeStyle: .short
                                        ))
                                    }
                                    .foregroundColor(.white)
                                }
                            }
                        }
                        .padding(20)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }

                    // Map
                    let focusStation = Station(
                        id:          parentStop.id,
                        name:        parentStop.name,
                        latitude:    parentStop.latitude,
                        longitude:   parentStop.longitude,
                        description: parentStop.description
                    )

                    StationsMapView(viewModel: stationVM, focusStation: focusStation)
                        .frame(height: 200)
                        .cornerRadius(12)
                        .padding(.horizontal, 24)
                }
                .padding(.vertical)
            }
        }
        .onAppear {
            stationVM.loadStations()
            // no need to startPollingArrivals here—HomeView already did
        }
        .onDisappear {
            stopVM.stopPollingArrivals()
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Route Details")
                    .font(.headline)
                    .foregroundColor(.white)
            }
        }
    }

    // LiveActivityCard (unchanged) …
}

// Preview (inject a dummy stopVM)
struct RouteDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleStop = Stop(
            id:          1,
            name:        "Main St & 3rd Ave",
            latitude:    45.5120,
            longitude:  -122.6587,
            description: "Near the library",
            trimetID:    123456
        )
        let sampleRoute = Route(
            id:           10,
            name:         "10 – Downtown",
            arrivalTime:  Int(Date().timeIntervalSince1970) + 300,
            direction:    "Northbound",
            realTime:     Int(Date().timeIntervalSince1970) + 300,
            isMAX:        false
        )
        NavigationStack {
            RouteDetailView(
                parentStop:  sampleStop,
                route:       sampleRoute,
                stopVM:      StopViewModel(),               // injected here
                navPath:     .constant(NavigationPath()),
                timeManager: TimeManager()
            )
        }
        .previewLayout(.sizeThatFits)
        .preferredColorScheme(.light)
    }
}
