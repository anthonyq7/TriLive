//
//  SpashView.swift
//  TriLive
//
//  Created by Anthony Qin on 6/6/25.
//

import SwiftUI

struct SpashView: View {
    
    @State var isActive: Bool = false
    
    var body: some View {
        
        ZStack{
            Color.appBackground.edgesIgnoringSafeArea(.all)
            
            if self.isActive {
                HomeView()
                    .transition(.scale)
            } else {
                SplashScreen()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation(.easeInOut(duration: 0.5)){
                                self.isActive = true
                            }
                        }
                    }
                    .transition(.opacity)
            }
        }
    }
}

#Preview {
    SpashView()
}


struct SplashScreen: View {
    var body: some View {
        ZStack{
            Color.appBackground.edgesIgnoringSafeArea(.all)
            
            Image("TriLiveLogo")
                .resizable()
                .frame(width: 250, height: 250)
                .scaledToFit()
                .padding(.bottom, 125)
        }
    }
}
