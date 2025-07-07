import SwiftUI
import Combine

struct RouteDetailView: View {
    let parentStop: Stop
    let route: Route
    @State private var isLiveActive = true
    @Binding var navPath: NavigationPath
    @ObservedObject var timeManager: TimeManager
    @StateObject private var stationVM = StationsViewModel()

    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                   
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

                    // stop button to exit live activity
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

                    // live activity section
                    if isLiveActive {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Live Activity In Progress…")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)

                            LiveActivityCard(timeManager: timeManager, route: route)
                        }
                        .padding(20)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        .padding(.vertical, 24)
                    }

                    // map or station focus view
                    if let focus = stationVM.stations.first(where: { $0.id == parentStop.id }) {
                        StationsMapView(
                            viewModel: stationVM,
                            focusStation: focus
                        )
                        .frame(height: 200)
                        .cornerRadius(12)
                        .padding(.horizontal, 24)
                    } else {
                        // placeholder while loading or on no match
                        ProgressView()
                            .frame(height: 200)
                            .padding(.horizontal, 24)
                    }
                }
                .onAppear {
                    stationVM.loadStations()
                    // fetch station data when view appears
                }
            }
        }
        .navigationTitle("Route Details")
        // set nav bar title
        
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }


    // nested view for live activity details
    struct LiveActivityCard: View {
        @ObservedObject var timeManager: TimeManager
        // observe timer updates
        let route: Route

        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(route.name)
                        .font(.headline)
                    Spacer()
                    Text(
                        "ETA: " +
                        DateFormatter.localizedString(
                            from: Date().addingTimeInterval(Double(route.minutesUntilArrival * 60)),
                            dateStyle: .none,
                            timeStyle: .short
                        )
                    )
                    .font(.subheadline)
                }

                Text("Your ride will be here in \(route.minutesUntilArrival) min\(route.minutesUntilArrival == 1 ? "" : "s")")
                    .font(.subheadline)

                // compute progress (note: let declarations not allowed directly in ViewBuilder)
                let progress = min(timeManager.timeDifferenceInMinutes(), Double(route.minutesUntilArrival))
                
                ProgressView(value: progress, total: Double(route.minutesUntilArrival))
            }
            .padding()
            .background(Color(.systemBackground).opacity(0.1))
            .cornerRadius(8)
        }
    }
}

// timer manager for live updates
class TimeManager: ObservableObject {
    @Published var currentTime: Date = Date()
    // current time published every second
    
    let oldTime: Date
    // timestamp when timer started
    
    private var timer: Timer?

    init() {
        self.oldTime = Date()
        startTime()
    }

    func startTime() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.currentTime = Date()
            // update every second
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
        // clean up timer
    }
}
