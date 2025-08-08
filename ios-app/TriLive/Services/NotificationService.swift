import Foundation
import UserNotifications

class NotificationService: ObservableObject {
    static let shared = NotificationService()
    private init() {}
    
    func requestPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
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
            print("- Authorization: \(settings.authorizationStatus.rawValue)")
            print("- Alerts: \(settings.alertSetting.rawValue)")
            print("- Sounds: \(settings.soundSetting.rawValue)")
            print("- Badges: \(settings.badgeSetting.rawValue)")
        }
    }
    
    func scheduleArrivalNotification(for arrival: Arrival, stopName: String) {
        cancelArrivalNotifications(for: arrival)
        let content = UNMutableNotificationContent()
        content.title = "Your ride has arrived!"
        content.body = "Route \(arrival.routeName) has arrived at \(stopName)"
        content.sound = .default
        // Use a minimum delay of 1 second to fire immediately if arrivalTime has passed
        let delay = arrival.arrivalDate.timeIntervalSinceNow
        let fireInterval = max(delay, 1)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: fireInterval, repeats: false)
        let request = UNNotificationRequest(identifier: "arrival_\(arrival.id)", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    func scheduleThreeMinuteNotification(for arrival: Arrival, stopName: String) {
        cancelThreeMinuteNotifications(for: arrival)
        let content = UNMutableNotificationContent()
        content.title = "Ride arriving soon!"
        content.body = "Route \(arrival.routeName) will arrive at \(stopName) in 3 minutes"
        content.sound = .default
        // Calculate lead time relative to now, fire immediately if already within 3 minutes
        let leadTime = arrival.arrivalDate.timeIntervalSinceNow - 180
        let fireInterval = max(leadTime, 1)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: fireInterval, repeats: false)
        let request = UNNotificationRequest(identifier: "three_min_\(arrival.id)", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    func cancelArrivalNotifications(for arrival: Arrival) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["arrival_\(arrival.id)"])
    }
    func cancelThreeMinuteNotifications(for arrival: Arrival) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["three_min_\(arrival.id)"])
    }
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
