import SwiftUI
import Combine

struct RouteDetailView: View {
    let parentStop: Stop
    let route: Route

    @Binding var navPath: NavigationPath
    @ObservedObject var timeManager: TimeManager

    @StateObject private var stationVM = StationsViewModel()

    @State private var isLiveActive = true

    // compute progress ahead of time
    private var progress: Double {
        min(timeManager.timeDifferenceInMinutes(), Double(route.minutesUntilArrival))
    }

    var body: some View {
        ZStack {
            // background
            Color.appBackground
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // — Header —
                    VStack(alignment: .leading, spacing: 1) {
                        Text(route.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text("Stop: \(parentStop.name)")
                            .font(.subheadline)
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 16)

                    // stop button
                    Button("Stop") {
                        isLiveActive = false
                        navPath.removeLast()
                        timeManager.stopTime()
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: 300)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(25)
                    .padding(.horizontal)

                    // live activity
                    if isLiveActive {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Live Activity In Progress…")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)

                            LiveActivityCard(timeManager: timeManager, route: route, progress: progress)
                        }
                        .padding(20)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        .padding(.vertical, 24)
                    }

                    // map or placeholder
                    Group {
                        if stationVM.isLoading {
                            ProgressView("Loading map…")
                                .frame(height: 200)
                        } else if stationVM.showError {
                            VStack {
                                Image(systemName: "exclamationmark.triangle")
                                Text("Failed to load stations")
                                Text(stationVM.errorMessage ?? "")
                                    .font(.caption2)
                            }
                            .foregroundColor(.red)
                            .frame(height: 200)
                        } else if let focus = stationVM.stations.first(where: { $0.id == parentStop.id }) {
                            StationsMapView(
                                viewModel: stationVM,
                                focusStation: focus
                            )
                            .frame(height: 200)
                            .cornerRadius(12)
                        } else {
                            Text("No station data available")
                                .frame(height: 200)
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .onAppear {
                    // reset and load stations
                    stationVM.loadStations()
                }
            }

            // overlay full-screen spinner if desired
            if stationVM.isLoading {
                Color.black.opacity(0.25).ignoresSafeArea()
            }
        }
        // alert for map-loading errors
        .alert("Station Load Error",
               isPresented: $stationVM.showError,
               actions: { Button("OK", role: .cancel) {} },
               message: { Text(stationVM.errorMessage ?? "Unknown error") }
        )
        .navigationTitle("Route Details")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }
}

struct LiveActivityCard: View {
    @ObservedObject var timeManager: TimeManager
    let route: Route
    let progress: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(route.name)
                    .font(.headline)
                Spacer()
                Text("ETA: " +
                     DateFormatter.localizedString(
                        from: Date().addingTimeInterval(Double(route.minutesUntilArrival * 60)),
                        dateStyle: .none,
                        timeStyle: .short
                     )
                )
                .font(.subheadline)
            }

            Text("Your ride will be here in \(route.minutesUntilArrival) min" +
                 (route.minutesUntilArrival == 1 ? "" : "s")
            )
            .font(.subheadline)

            ProgressView(value: progress, total: Double(route.minutesUntilArrival))
        }
        .padding()
        .background(Color(.systemBackground).opacity(0.1))
        .cornerRadius(8)
    }
}

// TimeManager remains unchanged

class TimeManager: ObservableObject {
    @Published var currentTime: Date = Date()
    let oldTime: Date
    private var timer: Timer?

    init() {
        self.oldTime = Date()
        startTime()
    }

    func startTime() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1,
                                     repeats: true) { _ in
            self.currentTime = Date()
        }
    }

    func stopTime() {
        timer?.invalidate()
        timer = nil
    }

    func timeDifferenceInMinutes() -> Double {
        return currentTime.timeIntervalSince(oldTime) / 60
    }

    deinit {
        timer?.invalidate()
    }
}
