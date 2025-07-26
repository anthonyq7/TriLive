import SwiftUI

struct ExtractedLogoAndWelcomeView: View {
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color("AccentColor"), Color("AccentColor").opacity(0.8)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 150, height: 150)
                    .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)

                Image("TriLiveLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
            }

            Text("Welcome to TriLive")
                .font(.system(size: 30, weight: .semibold))
                .foregroundColor(.white)

            Text("Real-time bus ETAs at your fingertips")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.top, 16)
    }
}
