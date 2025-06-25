//
//  SettingsView.swift
//  TriLive
//
//  Created by Anthony Qin on 6/6/25.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        ZStack{
            Color.appBackground.edgesIgnoringSafeArea(.all)
            
            VStack {
                
                HStack {
                    Text("Settings")
                        .foregroundStyle(Color.white)
                        .font(.system(size: 48, weight: .medium, design: .default))
                        .padding(.leading, 16)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                    
                    Spacer()
                    
                }
                .padding()
            } //VStack
        } // ZStack
    }
}

#Preview {
    SettingsView()
}

struct SettingsCard: View {
    var body: some View {
        
    }
}
