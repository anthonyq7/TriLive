// RouteDetailView.swift
// TriLive

import SwiftUI
import MapKit

struct RouteDetailView: View {
    let parentStop: Stop
    let route:      Route

    @ObservedObject var stopVM:     StopViewModel
    @Binding        var navPath:    NavigationPath
    @ObservedObject var timeManager: TimeManager

    @StateObject private var stationVM  = StationsViewModel()
    @StateObject private var arrivalsVM: ArrivalsViewModel
    @State        private var isLiveActive = true

    init(
        parentStop: Stop,
        route: Route,
        stopVM: StopViewModel,
        navPath: Binding<NavigationPath>,
        timeManager: TimeManager
    ) {
        self.parentStop  = parentStop
        self.route       = route
        self.stopVM      = stopVM
        self._navPath    = navPath
        self.timeManager = timeManager

        // Wire up arrivals view model for this stop+route
        _arrivalsVM = StateObject(
            wrappedValue: ArrivalsViewModel(
                stopId:  parentStop.id,
                routeId: route.routeId
            )
        )
    }

    var body: some View {
        ZStack {
            Color("AppBackground")
                .ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    header
                    stopButton
                    liveActivitySection
                    //upcomingArrivalsSection
                    mapSection
                }
                .padding(.vertical)
            }
            .onAppear(perform: onAppear)
            .onDisappear(perform: onDisappear)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar { toolbarContent() }
        }
    }

    // MARK: – Subviews

    private var header: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(Color(route.routeColor))
                .frame(width: 48, height: 48)
                .overlay(
                    Text("\(route.routeId)")
                        .font(.headline)
                        .foregroundColor(.white)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(route.routeName)
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
    }

    private var stopButton: some View {
        Button("Stop") {
            isLiveActive = false
            timeManager.stopTimer()
            stopVM.stopPollingArrivals()
            stopVM.selectedStop = nil
            navPath.removeLast()
        }
        .font(.headline)
        .foregroundColor(.white)
        .frame(maxWidth: 300)
        .padding()
        .background(Color.red)
        .cornerRadius(25)
        .padding(.horizontal)
    }

    private var liveActivitySection: some View {
        Group {
            if isLiveActive {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Live Activity In-Progress")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)

                    LiveActivityCard(timeManager: timeManager, route: route)
                }
                .padding(20)
                .background(Color.black.opacity(0.5))
                .cornerRadius(12)
                .padding(.horizontal)
            }
        }
    }

    private var upcomingArrivalsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Upcoming Arrivals")
                .font(.headline)
                .foregroundColor(.white)

            Group {
                if arrivalsVM.isLoading {
                    ProgressView()
                } else if let err = arrivalsVM.errorMessage {
                    Text(err)
                        .foregroundColor(.red)
                } else {
                    ForEach(arrivalsVM.arrivals) { arrival in
                        HStack {
                            Text("\(arrival.minutesUntilArrival) min")
                            Spacer()
                            Text(
                                DateFormatter
                                    .localizedString(
                                        from: arrival.arrivalDate,
                                        dateStyle: .none,
                                        timeStyle: .short
                                    )
                            )
                        }
                        .foregroundColor(.white)
                    }
                }
            }
        }
        .padding()
        .background(Color("AppBackground").opacity(0.5))
        .cornerRadius(12)
        .padding(.horizontal)
        .refreshable {
            await arrivalsVM.loadArrivals()
        }
    }

    private var mapSection: some View {
        StationsMapView(viewModel: stationVM, focusStation: parentStop)
            .frame(height: 200)
            .cornerRadius(12)
            .padding(.horizontal, 24)
    }

    @ToolbarContentBuilder
    private func toolbarContent() -> some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text("Route Details")
                .font(.headline)
                .foregroundColor(.white)
        }
    }

    // MARK: – Lifecycle

    private func onAppear() {
        Task {
            await stationVM.loadStations()
            timeManager.startTimer()
            arrivalsVM.startPolling()
        }
    }

    private func onDisappear() {
        timeManager.stopTimer()
        arrivalsVM.stopPolling()
    }
}


// Live Activity Card
struct LiveActivityCard: View {
    @ObservedObject var timeManager: TimeManager
    let route: Route
    

    var body: some View {
        let minutes  = ceil(timeManager.timeDifferenceInMinutes())
        let currentUnixTimeSeconds = Int(Date().timeIntervalSince1970)
        let etaUnixSeconds = Int(route.eta_unix/1000)
        let totalMin    = Int((etaUnixSeconds - currentUnixTimeSeconds)/60)
        let progress = min(Int(minutes), totalMin)

        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(route.routeName)
                    .font(.headline)
                Spacer()
                Text("ETA: " +
                    DateFormatter
                        .localizedString(
                            from: Date().addingTimeInterval(Double(totalMin) * 60),
                            dateStyle: .none,
                            timeStyle: .short
                        )
                )
                .font(.subheadline)
            }

            Text("Your ride will be here in \(Int(Double(totalMin) - minutes)) min\(Int(Double(totalMin) - minutes) == 1 ? "" : "s")")
                .font(.subheadline)

            ProgressView(value: Double(progress), total: Double(totalMin))
        }
        .padding()
        .background(Color("AppBackground").opacity(0.8))
        .cornerRadius(8)
        .foregroundColor(.white)
    }
}


// MARK: – Preview

struct RouteDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleStop = Stop(
            id: 1,
            name:   "Main St & 3rd Ave",
            lon:   -122.6587,
            lat:    45.5120,
            dir: "Southbound"
        )
        let sampleRoute = Route(
            stopId:     2,
            routeId:    10,
            routeName:  "10 – Downtown",
            status:     "IN_SERVICE",
            eta:        "5",
            routeColor: "green",
            eta_unix: 14332934123
        )

        NavigationStack {
            RouteDetailView(
                parentStop:  sampleStop,
                route:       sampleRoute,
                stopVM:      StopViewModel(),
                navPath:     .constant(NavigationPath()),
                timeManager: TimeManager()
            )
        }
        .previewLayout(.sizeThatFits)
        .preferredColorScheme(.light)
    }
}
