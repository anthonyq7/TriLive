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
                .fill(Color(colorFromHex(route.routeColor)))
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
                    
                    LiveActivityCard(timeManager: timeManager, route: route, stopVM: stopVM, arrivalsVM: arrivalsVM, navPath: $navPath, isLiveActive: $isLiveActive)
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
    
    private func colorFromHex(_ hex: String) -> Color {
        let sanitized = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: sanitized).scanHexInt64(&int)
        
        let a, r, g, b: Double
        switch sanitized.count {
            
        case 6:
            a = 1.0
            r = Double((int >> 16) & 0xFF) / 255.0
            g = Double((int >> 8) & 0xFF)  / 255.0
            b = Double(int & 0xFF)         / 255.0
            
        default:
            
            return Color.gray
        }
        
        return Color(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}


// Live Activity Card
struct LiveActivityCard: View {
    @ObservedObject var timeManager: TimeManager
    let route: Route
    @ObservedObject var stopVM: StopViewModel
    @StateObject var arrivalsVM: ArrivalsViewModel
    @Binding        var navPath:    NavigationPath
    @Binding var isLiveActive: Bool
    @State private var StartUnixTimeSeconds: Int = Int(Date().timeIntervalSince1970)
    
    
    var body: some View {
        let minutes  = ceil(timeManager.timeDifferenceInMinutes())
        let nextArrivalUnix = stopVM.routes.filter({$0.routeId == route.routeId}).first?.eta_unix ?? 0
        let etaUnixSeconds = Int(nextArrivalUnix)/1000
        let totalSec    = Int(etaUnixSeconds - StartUnixTimeSeconds)
        let CurrentUnixTime = Int(Date().timeIntervalSince1970)
        let progress = min(CurrentUnixTime - StartUnixTimeSeconds, totalSec)
        
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(route.routeName)
                    .font(.headline)
                Spacer()
                Text("ETA: " + convertUnixToTime(Int(nextArrivalUnix)))
                    .font(.subheadline)
            }
            
            Text("Your ride will be here in \(Int(etaUnixSeconds - CurrentUnixTime)/60 >= 1 ? String(Int(etaUnixSeconds - CurrentUnixTime)/60) : "<1") min\(Int(etaUnixSeconds - CurrentUnixTime)/60 <= 1 ? "" : "s")")
                .font(.subheadline)
            
            ProgressView(value: Double(progress), total: Double(totalSec))
                .onChange(of: progress){
                    if  CurrentUnixTime >= etaUnixSeconds{
                        isLiveActive = false
                        timeManager.stopTimer()
                        stopVM.stopPollingArrivals()
                        navPath.removeLast()
                    }
                    
                }
        }
        .padding()
        .background(Color("AppBackground").opacity(0.8))
        .cornerRadius(8)
        .foregroundColor(.white)
    }
}


func convertUnixToTime(_ unixTime: Int) -> String{
    let unix_seconds = TimeInterval(unixTime/1000)
    let date = Date(timeIntervalSince1970: unix_seconds)
    
    let Formatter = DateFormatter()
    Formatter.dateFormat = "h:mm a"
    Formatter.locale     = Locale.current
    Formatter.timeZone = .current
    
    return Formatter.string(from: date)
}

// MARK: – Preview

struct RouteDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleStop = Stop(
            stopId:      1001,
            name:        "Main St & 1st Ave",
            dir:         "Northbound",
            lon:         -122.662345,
            lat:         45.512789,
            dist:        0,
            description: nil
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
