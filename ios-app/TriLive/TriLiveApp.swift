//
//  TriLiveApp.swift
//  TriLive
//
//  Created by Anthony Qin on 6/6/25.
//

import SwiftUI
import UserNotifications

enum TabSelection: Int {
    case home = 0, favorites = 1, settings = 2
}

@main
struct TriLiveApp: App {
    @StateObject private var favoritesManager = FavoritesManager()
    @StateObject private var stopVM           = StopViewModel()
    @StateObject private var timeManager      = TimeManager()
    @StateObject private var locManager       = LocationManager()

    @State private var navPath     = NavigationPath()
    @State private var selectedTab = TabSelection.home

    var body: some Scene {
        WindowGroup {
            MainTabView(
                favoritesManager: favoritesManager,
                stopVM:           stopVM,
                timeManager:      timeManager,
                locationManager:  locManager,
                navigationPath:   $navPath,
                selectedTab:      $selectedTab
            )
            .preferredColorScheme(.dark)
            .onAppear {
                // Set the notification delegate
                UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
            }
        }
    }
}

// Notification delegate to handle notifications when app is in foreground
class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()
    
    private override init() {
        super.init()
    }
    
    // Handle notification when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Notification received while app is in foreground: \(notification.request.identifier)")
        // Show the notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    // Handle notification tap
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Notification tapped: \(response.notification.request.identifier)")
        completionHandler()
    }
}


