import SwiftUI
import MapKit

struct RouteDetailView: View {
    let parentStop: Stop
    let route:      Route
    
    @ObservedObject var stopVM:      StopViewModel
    @Binding        var navPath:     NavigationPath
    @ObservedObject var timeManager: TimeManager
    
    @StateObject private var stationVM  = StationsViewModel()
    @StateObject private var arrivalsVM: ArrivalsViewModel
    @State        private var isLiveActive = true
    
    private let cardRadius: CGFloat = 16
    private let cardShadow = Color.black.opacity(0.2)
    
    @StateObject private var vehicleTracker: VehicleTrackerViewModel
    
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
        _arrivalsVM = StateObject(
            wrappedValue: ArrivalsViewModel(
                stopId:  parentStop.id,
                routeId: route.routeId,
                vehicleId: route.vehicleId
            )
        )
        _vehicleTracker = StateObject(
            wrappedValue: VehicleTrackerViewModel(
                stopId: parentStop.id,
                routeId: route.routeId,
                vehicleId: route.vehicleId
            )
        )
    }

    
    var body: some View {
        ZStack {
            Color("AppBackground").ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    header
                    stopButton
                    
                    if isLiveActive {
                        liveActivitySection
                    }
                    
                    mapSection
                }
                .padding(.vertical)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear(perform: onAppear)
        .onDisappear(perform: onDisappear)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var header: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(Color(colorFromHex(route.routeColor)))
                .frame(width: 48, height: 48)
                .overlay(
                    Text("\(route.routeId)")
                        .font(.headline)
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 4) {
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
        .cornerRadius(cardRadius)
        .shadow(color: cardShadow, radius: 8, x: 0, y: 4)
        .padding(.horizontal)
    }
    
    private var stopButton: some View {
        Button(action: {
            isLiveActive = false
            timeManager.stopTimer()
            stopVM.stopPollingArrivals()
            vehicleTracker.stopTracking()
            navPath.removeLast()
        }) {
            Text("Stop")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red)
                .cornerRadius(cardRadius)
        }
        .padding(.horizontal)
    }
    
    private var liveActivitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Live Activity In-Progress")
                .font(.headline)
                .foregroundColor(.white)
            
            LiveProgressView(arrivals: arrivalsVM, isLiveActive: $isLiveActive, timeManager: timeManager, stopVM: stopVM, vehicleTracker: vehicleTracker, navPath: $navPath)
                .padding()
                .cornerRadius(cardRadius)
                .shadow(color: cardShadow, radius: 8, x: 0, y: 4)
        }
        .padding(.horizontal)
    }
    
    private var mapSection: some View {
        TrackingMapView(
            points: $vehicleTracker.positions,
            vehicleLocation: $vehicleTracker.currentPosition,
            stopLocation: CLLocationCoordinate2D(
                latitude: parentStop.lat,
                longitude: parentStop.lon
            )
        )
        .frame(height: 220)
        .cornerRadius(cardRadius)
        .shadow(color: cardShadow, radius: 8, x: 0, y: 4)
        .padding(.horizontal)
    }
    
    @ToolbarContentBuilder
    private func toolbarContent() -> some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text("Route Details")
                .font(.headline)
                .foregroundColor(.white)
        }
    }
    
    private func onAppear() {
        Task {
            await stationVM.loadStations()
            timeManager.startTimer()
            arrivalsVM.startPolling()
            vehicleTracker.startTracking()
        }
    }

    private func onDisappear() {
        timeManager.stopTimer()
        arrivalsVM.stopPolling()
        vehicleTracker.stopTracking()
    }
    
    private func colorFromHex(_ hex: String) -> Color {
        let sanitized = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: sanitized).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255.0
        let g = Double((int >> 8) & 0xFF) / 255.0
        let b = Double(int & 0xFF) / 255.0
        return Color(.sRGB, red: r, green: g, blue: b, opacity: 1)
    }
}
