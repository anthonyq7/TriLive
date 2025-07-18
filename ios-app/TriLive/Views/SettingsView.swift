import SwiftUI
import UIKit
import UserNotifications

// MARK: – UIKit share‐sheet wrapper for SwiftUI
struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: – Reusable row: toggle or tappable button
struct SettingsCard: View {
    let iconName: String
    let title: String
    var isToggle = false
    @Binding var toggleValue: Bool
    var action: (() -> Void)? = nil

    var body: some View {
        HStack {
            Image(systemName: iconName)
                .font(.title2)
                .frame(width: 32)
                .foregroundColor(.accentColor)

            Text(title)
                .font(.body)
                .foregroundColor(.white)

            Spacer()

            if isToggle {
                Toggle("", isOn: $toggleValue)
                    .labelsHidden()
            } else if action != nil {
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color("CardBackground"))
        .cornerRadius(12)
        .onTapGesture {
            guard !isToggle else { return }
            action?()
        }
    }
}

// MARK: – Settings screen itself
struct SettingsView: View {
    @ObservedObject var locationManager: LocationManager   // inject your manager here

    // persisted toggles
    @AppStorage("pushNotifications") private var pushNotifications = true
    @AppStorage("locationSharing")   private var locationSharing   = true

    // sheet‐flag
    @State private var showShareSheet = false

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    HStack {
                        Text("Settings")
                            .font(.system(size: 36, weight: .semibold))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.horizontal)

                    // Notifications
                    VStack(spacing: 12) {
                        Text("Notifications")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        SettingsCard(
                            iconName: "bell.fill",
                            title: "Push Notifications",
                            isToggle: true,
                            toggleValue: $pushNotifications
                        )
                    }
                    .padding(.horizontal)

                    // Privacy
                    VStack(spacing: 12) {
                        Text("Privacy")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        SettingsCard(
                            iconName: "location.fill",
                            title: "Location Sharing",
                            isToggle: true,
                            toggleValue: $locationSharing
                        )
                    }
                    .padding(.horizontal)

                    // Extras
                    VStack(spacing: 12) {
                        Text("Extras")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        SettingsCard(
                            iconName: "star.fill",
                            title: "Rate Me",
                            toggleValue: .constant(false)
                        ) {
                            openAppStoreReview()
                        }

                        SettingsCard(
                            iconName: "square.and.arrow.up",
                            title: "Share with Friends",
                            toggleValue: .constant(false)
                        ) {
                            showShareSheet = true
                        }
                    }
                    .padding(.horizontal)

                    // General
                    VStack(spacing: 12) {
                        Text("General")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        SettingsCard(
                            iconName: "info.circle",
                            title: "App Version 1.0.0",
                            toggleValue: .constant(false)
                        )

                        SettingsCard(
                            iconName: "questionmark.circle",
                            title: "Help & Feedback",
                            toggleValue: .constant(false)
                        ) {
                            openFeedback()
                        }
                    }
                    .padding(.horizontal)

                    Spacer(minLength: 50)
                }
                .padding(.top)
            }
        }
        // MARK: side‐effects when toggles change
        .onChange(of: pushNotifications) { enabled in
            if enabled {
                UNUserNotificationCenter.current()
                    .requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
                UIApplication.shared.registerForRemoteNotifications()
            } else {
                UIApplication.shared.unregisterForRemoteNotifications()
            }
        }
        .onChange(of: locationSharing) { enabled in
            if enabled {
                locationManager.startUpdatingLocation()
            } else {
                locationManager.stopUpdatingLocation()
            }
        }
        // MARK: share sheet
        .sheet(isPresented: $showShareSheet) {
            ActivityView(activityItems: ["Check out TriLive—the simplest transit ETA app!"])
        }
    }

    // MARK: – Actions
    private func openAppStoreReview() {
        let appID = "YOUR_APP_ID"
        guard let url = URL(
            string: "itms-apps://itunes.apple.com/app/id\(appID)?action=write-review"
        ) else { return }
        UIApplication.shared.open(url)
    }

    private func openFeedback() {
        guard let url = URL(string: "mailto:support@trilive.com") else { return }
        UIApplication.shared.open(url)
    }
}

// MARK: – Preview
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        // pass in your real LocationManager singleton or instance
        SettingsView(locationManager: LocationManager())
            .preferredColorScheme(.dark)
    }
}
