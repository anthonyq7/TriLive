//
//  ContentView.swift
//  TriLive
//
//  Created by Anthony Qin on 6/6/25.
//

import SwiftUI

struct HomeView: View {
    @State private var chosenStop: String = ""
    @State private var stopFound: Bool = false
    @State private var isStarted: Bool = false
    
    var body: some View {
        ZStack{
            
            Color.appBackground.edgesIgnoringSafeArea(.all)
            
            ScrollView(.vertical, showsIndicators: false) {
                
                VStack{
                    
                    Image("TriLiveLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 150, height: 150)
                        .padding(.top, 25)
                    
                    HStack{
                        Text("Welcome!")
                            .foregroundStyle(Color.white)
                            .font(.system(size: 48, weight: .medium, design: .default))
                            .padding(.leading, 24)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                        
                        Spacer()
                    }
                    .padding()
                    
                    searchBar(text: $chosenStop)
                
                    HStack{
                        
                        if chosenStop.isEmpty && !stopFound {
                            Text("Favorite Routes")
                                .foregroundStyle(Color.white)
                                .font(.title2)
                                .padding(.leading, 24)
                                .lineLimit(1)
                                .minimumScaleFactor(0.75)
                            
                            Spacer()
                        } else {
                            Text("Available Routes")
                                .foregroundStyle(Color.white)
                                .font(.title2)
                                .padding(.leading, 24)
                                .lineLimit(1)
                                .minimumScaleFactor(0.75)
                            
                            Spacer()
                        }
                        
                    }
                    .padding(.top, 24)
                    
                    List {
                        
                    }
                    
                
                } //VStack
            } //ScrolView
            
        } //Zstack

    }
}

#Preview {
    HomeView()
}

struct searchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack{
            
            TextField("Enter a stop", text: $text)
                .lineLimit(1)
                .truncationMode(.tail)
                .foregroundStyle(Color.appBackground)
            
            Image(systemName: "magnifyingglass")
            
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray)
        )
        .padding(.horizontal, 24)
    }
}
