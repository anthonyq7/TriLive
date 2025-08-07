import Foundation
import UserNotifications

class NotificationService: ObservableObject {
    static let shared = NotificationService()
    
    private init() {}
    
    func requestPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
            print("Notification permission granted: \(granted)")
            return granted
        } catch {
            print("Notification permission error: \(error)")
            return false
        }
    }
    
    func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Notification settings:")
            print("- Authorization status: \(settings.authorizationStatus.rawValue)")
            print("- Alert setting: \(settings.alertSetting.rawValue)")
            print("- Sound setting: \(settings.soundSetting.rawValue)")
            print("- Badge setting: \(settings.badgeSetting.rawValue)")
        }
    }
    
                    func scheduleArrivalNotification(for arrival: Arrival, stopName: String) {
                    // Remove any existing notifications for this arrival
                    cancelArrivalNotifications(for: arrival)

                    let content = UNMutableNotificationContent()
                    content.title = "Your ride has arrived!"
                    content.body = "Route \(arrival.routeName) has arrived at \(stopName)"
                    content.sound = .default

                    // Schedule notification for when arrival time is reached
                    let timeUntilArrival = arrival.arrivalDate.timeIntervalSinceNow
                    print("Scheduling arrival notification for \(arrival.routeName) in \(timeUntilArrival) seconds")

                    if timeUntilArrival > 0 {
                        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeUntilArrival, repeats: false)
                        let request = UNNotificationRequest(identifier: "arrival_\(arrival.id)", content: content, trigger: trigger)

                        UNUserNotificationCenter.current().add(request) { error in
                            if let error = error {
                                print("Error scheduling arrival notification: \(error)")
                            } else {
                                print("Successfully scheduled arrival notification for \(arrival.routeName)")
                            }
                        }
                    } else {
                        print("Arrival time has already passed, not scheduling notification")
                    }
                }
    
                    func scheduleThreeMinuteNotification(for arrival: Arrival, stopName: String) {
                    // Removes any existing 3-minute notifications for this arrival
                    cancelThreeMinuteNotifications(for: arrival)

                    let content = UNMutableNotificationContent()
                    content.title = "Ride arriving soon!"
                    content.body = "Route \(arrival.routeName) will arrive at \(stopName) in 3 minutes"
                    content.sound = .default

                    // Schedules notification for 3 minutes before arrival
                    let threeMinutesBefore = arrival.arrivalDate.timeIntervalSinceNow - (3 * 60)
                    print("Scheduling 3-minute notification for \(arrival.routeName) in \(threeMinutesBefore) seconds")

                    if threeMinutesBefore > 0 {
                        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: threeMinutesBefore, repeats: false)
                        let request = UNNotificationRequest(identifier: "three_min_\(arrival.id)", content: content, trigger: trigger)

                        UNUserNotificationCenter.current().add(request) { error in
                            if let error = error {
                                print("Error scheduling 3-minute notification: \(error)")
                            } else {
                                print("Successfully scheduled 3-minute notification for \(arrival.routeName)")
                            }
                        }
                    } else {
                        print("3-minute notification time has already passed, not scheduling")
                    }
                }
    
    func cancelArrivalNotifications(for arrival: Arrival) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["arrival_\(arrival.id)"])
    }
    
                    func cancelThreeMinuteNotifications(for arrival: Arrival) {
                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["three_min_\(arrival.id)"])
                }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    
} 
