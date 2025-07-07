import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()

            VStack {
                Image("TriLiveLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
                    .padding(.bottom, 125)
            }
        }
    }
}

#Preview {
    SplashView()
}
