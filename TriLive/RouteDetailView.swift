import SwiftUI
import Combine

struct RouteDetailView: View {
    let parentStop: Stop
    let route: Route
    @State private var isLiveActive = true
    @Binding var navPath: NavigationPath
    @ObservedObject var timeManager: TimeManager
    
    var body: some View {
        ZStack {
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
                    
                    //for the stop button
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
                    
                    //live activity section
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
                    
                    //shows other options on the route that can be selected
                    /*
                     VStack(alignment: .leading, spacing: 12) {
                     Text("Other Routes at this stop")
                     .font(.headline)
                     .foregroundColor(.white)
                     
                     ForEach(parentStop.routeList.filter { $0.id != route.id }) { other in
                     NavigationLink(value: other) {
                     RouteCard(
                     parentStop: parentStop,
                     line: other,
                     isSelected: false,
                     onTap: { },
                     isFavorited: false,
                     toggleFavorite: { }
                     )
                     .background(Color(.systemBackground))
                     .cornerRadius(24)
                     .padding(.horizontal)
                     }
                     }
                     .padding(.horizontal)
                     }
                     .padding(.vertical)*/
                }
            }
            .navigationTitle("Route Details")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
        }
    }
    
    
    struct LiveActivityCard: View {
        @ObservedObject var timeManager: TimeManager
        let route: Route
        //will be function when we actually have real time data but just filler for now
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
                
                let progress = min(timeManager.timeDifferenceInMinutes(), Double(route.minutesUntilArrival))
                
                ProgressView(value: progress, total: Double(route.minutesUntilArrival))
            }
        }
    }
}

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
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.currentTime = Date()
        }
    }
    
    deinit {
        timer?.invalidate()
    }
    
    func stopTime(){
        timer?.invalidate()
        timer = nil
    }
    
    func timeDifferenceInMinutes() -> Double {
        return currentTime.timeIntervalSince(oldTime) / 60
    }
}

/*
 struct RouteDetailView_Previews: PreviewProvider {
 
 @Binding var navPath: NavigationPath
 
 static var previews: some View {
 NavigationStack {
 RouteDetailView(
 parentStop: stops[0],
 route:      stops[0].routeList[2],
 navPath: $navigationPath
 )
 }
 }
 }
 */




