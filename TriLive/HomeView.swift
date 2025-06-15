//
//  ContentView.swift
//  TriLive
//
//  Created by Anthony Qin on 6/6/25.
//

import SwiftUI

struct HomeView: View {
    
    @State private var searchQuery: String = ""
    @State private var stopSelected: Bool = false
    
    var stops = [
        Stop(id: 258, name: "Hawthorne & 12th"),
        Stop(id: 259, name: "Hawthorne & 14th"),
        Stop(id: 260, name: "Belmont & 34th"),
        Stop(id: 261, name: "Burnside & 20th"),
        Stop(id: 262, name: "Hawthorne & 16th"),
        Stop(id: 263, name: "Hawthorne & 18th")
    ]
    
    //dummy list of stops
    var filteredStops: [Stop] {
        return stops.filter { $0.name.localizedCaseInsensitiveContains(searchQuery)}
    }
    
    var body: some View {
        ZStack{
            
            Color.appBackground.edgesIgnoringSafeArea(.all)
            
            //Allows for scrolling
            ScrollView(.vertical, showsIndicators: false) {
                
                VStack{
                    
                    Image("TriLiveLogo") //Logo
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 150, height: 150)
                        .padding(.top, 25)
                    
                    HStack{
                        Text("Welcome!") //This is the header
                            .foregroundStyle(Color.white)
                            .font(.system(size: 48, weight: .medium, design: .default))
                            .padding(.leading, 16)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                        
                        Spacer()
                    }
                    .padding()
                    
                    //Peep below for extracted structure of searchBar
                    searchBar(searchQuery: $searchQuery, stopSelected: $stopSelected, stopList: filteredStops)
                    
                    ZStack {
                        //Still need to figure out how to make list below
                        //in z-axis when entering in a stop
                        HStack{
                            
                            if !stopSelected {
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
                    }
                } //VStack
            } //ScrollView
            
        } //Zstack
    }
}

#Preview {
    HomeView()
}

struct searchBar: View {
    
    @Binding var searchQuery: String
    @Binding var stopSelected: Bool
    
    var stopList: [Stop]
    
    var body: some View {
        VStack (spacing: 0) { //spacing 0 so that the stop list is seamless
            HStack{ //This is the textfield and icon area
                TextField("Enter a stop", text: $searchQuery)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .foregroundStyle(Color.appBackground)
                    .autocapitalization(.none)
                    .autocorrectionDisabled(true)
                
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
            .onChange(of: searchQuery) {
                if searchQuery.isEmpty {
                    stopSelected = false
                }
            } //used some rectangles and outlines to shape it
            
            //Below is the logic of the result list
            if !searchQuery.isEmpty && !stopList.isEmpty && !stopSelected{
                ScrollView {
                    LazyVStack{ //allows for only a set number of stops to be rendered
                        ForEach(stopList) { stop in
                            Text(stop.name + " (Stop " + stop.id.description + ")")
                                .padding(12)
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.white)
                                .onTapGesture {
                                    searchQuery = stop.name
                                    stopSelected = true
                                }
                            
                            Divider() //gives those partitions
                        }
                    }
                }
                .frame(height: 150)
                .background(Color.white)
                .padding(.horizontal, 38)
            }
        }
    }
}
