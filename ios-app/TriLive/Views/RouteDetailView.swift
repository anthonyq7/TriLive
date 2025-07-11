import SwiftUI
import MapKit

struct RouteDetailView: View {
    let parentStop: Stop
    let route: Route
    @Binding var navPath: NavigationPath
    @ObservedObject var timeManager: TimeManager
    @StateObject private var stopVM = StopViewModel()
    @State private var isLiveActive = true
    @StateObject private var stationVM = StationsViewModel()

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

                    //Stop Button
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

                    // Next Arrivals
                    if isLiveActive {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Next Arrivals")
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

                    //Map
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
        // Lifecycle & navigation modifiers
        .onAppear {
            stationVM.loadStations()
            stopVM.startPollingArrivals(for: parentStop)
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

    //LiveActivityCard
    struct LiveActivityCard: View {
        @ObservedObject var timeManager: TimeManager
        let route: Route

        var body: some View {
            let minutes = route.minutesUntilArrival
            let progress = min(timeManager.timeDifferenceInMinutes(), Double(minutes))

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(route.name)
                        .font(.headline)
                    Spacer()
                    Text(
                        "ETA: " +
                        DateFormatter.localizedString(
                            from: Date().addingTimeInterval(Double(minutes * 60)),
                            dateStyle: .none,
                            timeStyle: .short
                        )
                    )
                    .font(.subheadline)
                }

                Text(
                    "Your ride will be here in \(minutes) min" +
                    (minutes == 1 ? "" : "s")
                )
                .font(.subheadline)

                ProgressView(value: progress, total: Double(minutes))
            }
            .padding()
            .background(Color("AppBackground").opacity(0.8))
            .cornerRadius(8)
            .foregroundColor(.white)
        }
    }
}

//TimeManager
class TimeManager: ObservableObject {
    @Published var currentTime: Date = Date()
    private let startDate: Date
    private var timer: Timer?

    init() {
        startDate = Date()
        startTimer()
    }

    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.currentTime = Date()
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    func timeDifferenceInMinutes() -> Double {
        currentTime.timeIntervalSince(startDate) / 60
    }

    deinit {
        timer?.invalidate()
    }
}

// Preview
struct RouteDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleStop = Stop(
            id: 1,
            name: "Main St & 3rd Ave",
            latitude: 45.5120,
            longitude: -122.6587,
            description: "Near the library"
        )
        let sampleRoute = Route(
            id: 10,
            name: "10 – Downtown",
            arrivalTime: Int(Date().timeIntervalSince1970) + 300,
            direction: "Northbound",
            realTime: Int(Date().timeIntervalSince1970) + 300,
            isMAX: false
        )
        NavigationStack {
            RouteDetailView(
                parentStop:  sampleStop,
                route:       sampleRoute,
                navPath:     .constant(NavigationPath()),
                timeManager: TimeManager()
            )
        }
        .previewLayout(.sizeThatFits)
        .preferredColorScheme(.light)
    }
}
