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
    @StateObject private var notificationService = NotificationService.shared
    
    // Tracks which notifications have been sent to prevent duplicates
    @State private var sentArrivalNotifications: Set<String> = []
    @State private var sentThreeMinuteNotifications: Set<String> = []
    
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
        .onChange(of: arrivalsVM.arrivals) { newArrivals in
            print("Arrivals changed in RouteDetailView, count: \(newArrivals.count)")
            if let next = newArrivals.first {
                // Only schedule notifications for the current route being tracked
                if next.routeId == route.routeId {
                    print("Arrivals updated in RouteDetailView: \(next.routeName)")
                    print("Minutes until arrival: \(next.minutesUntilArrival)")
                    
                    // Check if arrival notification has already been sent
                    let arrivalId = next.id.uuidString
                    if !sentArrivalNotifications.contains(arrivalId) {
                        notificationService.scheduleArrivalNotification(for: next, stopName: parentStop.name)
                        sentArrivalNotifications.insert(arrivalId)
                        print("Scheduled arrival notification for arrival ID: \(arrivalId)")
                    } else {
                        print("Arrival notification already sent for arrival ID: \(arrivalId)")
                    }
                    
                    // Check if 3-minute notification has already been sent
                    if !sentThreeMinuteNotifications.contains(arrivalId) {
                        notificationService.scheduleThreeMinuteNotification(for: next, stopName: parentStop.name)
                        sentThreeMinuteNotifications.insert(arrivalId)
                        print("Scheduled 3-minute notification for arrival ID: \(arrivalId)")
                    } else {
                        print("3-minute notification already sent for arrival ID: \(arrivalId)")
                    }
                } else {
                    print("Skipping notification for route \(next.routeId) - not the tracked route \(route.routeId)")
                }
            } else {
                print("No arrivals in onChange handler")
            }
        }
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
            
            LiveProgressView(arrivals: arrivalsVM, isLiveActive: $isLiveActive, timeManager: timeManager, stopVM: stopVM, vehicleTracker: vehicleTracker, navPath: $navPath, stopName: parentStop.name)
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
            
            // Request notification permission and schedule notifications
            let granted = await notificationService.requestPermission()
            print("Permission request result: \(granted)")
            notificationService.checkNotificationStatus()
            
            if granted {
                print("Notification permission granted in RouteDetailView")
                // Schedule notifications when arrivals are loaded
                await scheduleNotificationsWhenArrivalsLoad()
            } else {
                print("Notification permission denied in RouteDetailView")
            }
        }
    }

    private func onDisappear() {
        timeManager.stopTimer()
        arrivalsVM.stopPolling()
        vehicleTracker.stopTracking()
        notificationService.cancelAllNotifications()
        
        // Clear notification tracking for next session
        sentArrivalNotifications.removeAll()
        sentThreeMinuteNotifications.removeAll()
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
    
    private func scheduleNotificationsWhenArrivalsLoad() async {
        // Wait a bit for arrivals to load
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        
        print("Checking arrivals for notifications...")
        print("Total arrivals: \(arrivalsVM.arrivals.count)")
        
        if let next = arrivalsVM.arrivals.first {
            // Only schedule notifications for the current route being tracked
            if next.routeId == route.routeId {
                print("Scheduling notifications for arrival: \(next.routeName) at \(next.arrivalDate)")
                print("Minutes until arrival: \(next.minutesUntilArrival)")
                
                // Check if arrival notification has already been sent
                let arrivalId = next.id.uuidString
                if !sentArrivalNotifications.contains(arrivalId) {
                    notificationService.scheduleArrivalNotification(for: next, stopName: parentStop.name)
                    sentArrivalNotifications.insert(arrivalId)
                    print("Scheduled arrival notification for arrival ID: \(arrivalId)")
                } else {
                    print("Arrival notification already sent for arrival ID: \(arrivalId)")
                }
                
                // Check if 3-minute notification has already been sent
                if !sentThreeMinuteNotifications.contains(arrivalId) {
                    notificationService.scheduleThreeMinuteNotification(for: next, stopName: parentStop.name)
                    sentThreeMinuteNotifications.insert(arrivalId)
                    print("Scheduled 3-minute notification for arrival ID: \(arrivalId)")
                } else {
                    print("3-minute notification already sent for arrival ID: \(arrivalId)")
                }
            } else {
                print("Skipping notification for route \(next.routeId) - not the tracked route \(route.routeId)")
            }
        } else {
            print("No arrivals available for notification scheduling")
        }
    }
}
