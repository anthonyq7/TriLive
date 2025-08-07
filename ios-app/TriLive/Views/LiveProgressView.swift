import SwiftUI

struct LiveProgressView: View {
    @ObservedObject var arrivals: ArrivalsViewModel
    @State private var startUnixTime: Int = Int(Date().timeIntervalSince1970)
    @Binding var isLiveActive: Bool
    @ObservedObject var timeManager: TimeManager
    @ObservedObject var stopVM: StopViewModel
    @ObservedObject var vehicleTracker: VehicleTrackerViewModel
    @Binding var navPath: NavigationPath
    let stopName: String
    @StateObject private var notificationService = NotificationService.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let next = arrivals.arrivals.first {
                let nextArrivalUnix = Int(next.arrivalDate.timeIntervalSince1970)
                let totalSec = max(nextArrivalUnix - startUnixTime, 1)
                let currentUnix = Int(Date().timeIntervalSince1970)
                let elapsed = min(max(currentUnix - startUnixTime, 0), totalSec)
                
                HStack {
                    Text("ETA: \(convertUnixToTime(nextArrivalUnix))")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Spacer()
                    Text("\(next.minutesUntilArrival) min")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                ProgressView(value: Double(elapsed), total: Double(totalSec))
                    .progressViewStyle(.linear)
                    .accentColor(Color("AccentColor"))
                    .frame(height: 4)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(2)
                    .onChange(of: elapsed) { newValue in
                        if Double(newValue) >= Double(totalSec) {
                            // Cancel all notifications when tracking stops
                            notificationService.cancelAllNotifications()
                            isLiveActive = false
                            timeManager.stopTimer()
                            stopVM.stopPollingArrivals()
                            vehicleTracker.stopTracking()
                            navPath.removeLast()
                        }
                    }
            } else {
                Text("No upcoming arrivals")
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .onAppear {
            startUnixTime = Int(Date().timeIntervalSince1970)
        }
    }
}


func convertUnixToTime(_ unixTime: Int) -> String {
    let date = Date(timeIntervalSince1970: TimeInterval(unixTime))
    let formatter = DateFormatter()
    formatter.dateStyle = .none
    formatter.timeStyle = .short
    return formatter.string(from: date)
}
