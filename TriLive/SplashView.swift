//
//  SplashView.swift
//  TriLive
//
//  Created by Anthony Qin on 6/12/25.
//


//
//  SpashView.swift
//  TriLive
//
//  Created by Anthony Qin on 6/6/25.
//

import SwiftUI

struct SplashView: View {
    
    @State var isActive: Bool = false
    
    var body: some View {
        
        ZStack{
            Color.appBackground.edgesIgnoringSafeArea(.all)
            
            if self.isActive {
                MainTabView()
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
            }
        }
    }
}

#Preview {
    SplashView()
}


struct SplashScreen: View {
    var body: some View {
        ZStack{
            Color.appBackground.edgesIgnoringSafeArea(.all)
            
            VStack {
                Image("TriLiveLogo")
                    .resizable()
                    .frame(width: 250, height: 250)
                    .scaledToFit()
                    .padding(.bottom, 125)
                
            }
        }
    }
}
