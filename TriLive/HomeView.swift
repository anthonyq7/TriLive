//
//  ContentView.swift
//  TriLive
//
//  Created by Anthony Qin on 6/6/25.
//

import SwiftUI

//DUMMY DATA BELOW
let dummyRoutes1 = [
    Route(id: 12, name: "Line 12 - Barbur/Sandy Blvd", arrivalTime: 1545, direction: "Eastbound to Sandy", realTime: 1559, isMAX: false),
    Route(id: 75, name: "Line 75 - Chavez/Lombard", arrivalTime: 1550, direction: "Northbound to Lombard", realTime: 1551, isMAX: false),
    Route(id: 1, name: "MAX Green Line", arrivalTime: 1548, direction: "Southbound to Clackamas",realTime: 1550, isMAX: true),
    Route(id: 2, name: "MAX Blue Line", arrivalTime: 1553, direction: "Eastbound to Gresham", realTime: 1553, isMAX: true)
]


let dummyRoutes2 = [
    Route(id: 72,name: "Line 72 - Killingsworth/82nd Ave",arrivalTime: 1600, direction: "Southbound to Clackamas Town Center", realTime: 1603,isMAX: false),
    Route(id: 19,name: "Line 19 - Woodstock/Glisan",arrivalTime: 1605,direction: "Eastbound to Gateway Transit Center",realTime: 1607,isMAX: false),
    Route(id: 3,name: "MAX Red Line",arrivalTime: 1602,direction: "Westbound to Beaverton TC",realTime: 1601,isMAX: true)
]

let stops = [
    Stop(
        id: 258,
        name: "Hawthorne & 12th",
        routeList: dummyRoutes1
    ),
    Stop(
        id: 312,
        name: "NE 82nd & Glisan",
        routeList: dummyRoutes2
    )
]

//START OF HomeView
struct HomeView: View {
    
    @State private var searchQuery: String = ""
    @State private var stopSelected: Bool = false
    @State var selectedStop: Stop = Stop(id: 0, name: "Placeholder", routeList: [])
    @State var selectedRoute: Route = Route(id: 0, name: "Placeholder", arrivalTime: 0, direction: "Placeholder", realTime: 0, isMAX: false)
    
    var filteredStops: [Stop] {
        return stops.filter {
            $0.name.localizedCaseInsensitiveContains(searchQuery) || String($0.id).contains(searchQuery)
        }
    }
    
    var body: some View {
        //Allows for scrolling
        ScrollView(.vertical, showsIndicators: false) {
            
            ZStack{
                
                Color.appBackground.edgesIgnoringSafeArea(.all)
                    .zIndex(0)
            
                VStack{
                    
                    ExtractedLogoAndWelcomeView()
                    
                    //Peep below for extracted structure of searchBar
                    searchBar(searchQuery: $searchQuery, stopSelected: $stopSelected, selectedStop: $selectedStop, stopList: filteredStops)
                    
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
                            VStack (alignment: .leading) {
                                Text("Available Routes")
                                    .foregroundStyle(Color.white)
                                    .font(.title2)
                                    .padding(.leading, 24)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.75)
                                
                                
                                Spacer()
                                
                                LazyVStack (alignment: .center) {
                                    
                                    //Sorts by real arrival time
                                    let routeList = selectedStop.routeList.sorted { $0.realTime < $1.realTime }
                                    
                                    //The available routes and their route cards
                                    ForEach(routeList){ route in
                                        RouteCard(parentStop: selectedStop, line: route)
                                            .padding(.vertical, 10)
                                            .padding(.horizontal, 15)
                                    } //ForEach
                                } //VStack
                            } //VStack
                        } //else
                    } //HStack
                    .padding(.top, 24)
                    .zIndex(1)
                } //VStack
                .zIndex(2)
            } //ZStack
        } //ScrollView
        .background(Color.appBackground)
    }
}

#Preview {
    HomeView()
}

struct searchBar: View {
    
    @Binding var searchQuery: String
    @Binding var stopSelected: Bool
    @Binding var selectedStop: Stop
    
    var stopList: [Stop]
    
    var body: some View {
        LazyVStack (spacing: 0) { //spacing 0 so that the stop list is seamless
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
                    .stroke(Color.black)
            )
            .padding(.horizontal, 24)
            .onChange(of: searchQuery) {
                if searchQuery.isEmpty {
                    selectedStop = Stop(id: 0, name: "Placeholder", routeList: [])
                    stopSelected = false
                }
            } //used some rectangles and outlines to shape it
            
            //Below is the logic of the result list
            if !searchQuery.isEmpty && !stopSelected{
                ScrollView {
                    LazyVStack{ //allows for only a set number of stops to be rendered
                        
                        HStack {
                            Text("Use Current Location")
                            
                            Spacer()
                            
                            Image(systemName: "location.fill")
                                .foregroundColor(.black)
                        }
                        .padding(12)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white) //Need to add .onTapGesture
                
                        ForEach(stopList) { stop in
                            Text(stop.name + " (Stop " + stop.id.description + ")")
                                .padding(12)
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.white)
                                .onTapGesture {
                                    searchQuery = stop.name
                                    selectedStop = stop
                                    stopSelected = true
                                }
                            
                            Divider() //gives those partitions
                        }
                    }
                }
                .frame(maxHeight: 150)
                .background(Color.white)
                .padding(.horizontal, 38)
            }
        }
    }
}

struct ExtractedLogoAndWelcomeView: View { //MUST PLACE IN VSTACK
    
    var body: some View {
        
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
    }
}
