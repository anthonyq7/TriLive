import SwiftUI
import UIKit
import UserNotifications

// UIKit share-sheet wrapper for SwiftUI
struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// Reusable settings row
struct SettingsCard: View {
    let iconName: String
    let title: String
    var isToggle = false
    @Binding var toggleValue: Bool
    var action: (() -> Void)?
    
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
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 3)
        .onTapGesture { if !isToggle { action?() } }
    }
}

struct SettingsView: View {
    @ObservedObject var locationManager: LocationManager
    @State private var showShareSheet = false
    
    var body: some View {
        ZStack {
            Color("AppBackground").ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    HStack {
                        Text("Settings")
                            .font(.system(size: 34, weight: .semibold))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    // Permissions section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Permissions")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        SettingsCard(
                            iconName: "gear",
                            title: "Manage Permissions",
                            toggleValue: .constant(false)
                        ) {
                            openSettings()
                        }
                    }
                    .padding(.horizontal)
                    
                    // Extras section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Extras")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
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
                    
                    // General section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("General")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        SettingsCard(
                            iconName: "info.circle",
                            title: "App Version 1.0.0",
                            toggleValue: .constant(false),
                            action: nil
                        )
                        
                        SettingsCard(
                            iconName: "questionmark.circle",
                            title: "Help & Feedback",
                            toggleValue: .constant(false)
                        ) {
                            openFeedback()
                        }
                        
                        Spacer(minLength: 20)
                        Text("TriMet data. Not affiliated with TriMet.")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ActivityView(activityItems: ["Check out TriLive—the simplest transit ETA app!"])
        }
    }
    
    private func openSettings() {
        // Debug: Print bundle identifier
        print("Bundle identifier: \(Bundle.main.bundleIdentifier ?? "nil")")
        
        // Open directly to this app's settings page
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            print("Opening settings URL: \(settingsUrl)")
            UIApplication.shared.open(settingsUrl)
        }
    }
    
    private func openAppStoreReview() {
        let appID = "YOUR_APP_ID"
        if let url = URL(string: "itms-apps://itunes.apple.com/app/id\(appID)?action=write-review") {
            UIApplication.shared.open(url)
        }
    }
    
    private func openFeedback() {
        if let url = URL(string: "mailto:support@trilive.com") {
            UIApplication.shared.open(url)
        }
    }
}


#Preview {
    SettingsView(locationManager: LocationManager())
}
