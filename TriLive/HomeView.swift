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
    @Binding var favoriteRouteIDs: Set<Int>
    
    @State private var searchQuery: String = ""
    @State private var stopSelected: Bool = false
    
    @State private var selectedRouteID: Int? = nil
    
    @State var selectedStop: Stop = Stop(id: 0, name: "Placeholder", routeList: [])
    @State var selectedRoute: Route = Route(id: 0, name: "Placeholder", arrivalTime: 0, direction: "Placeholder", realTime: 0, isMAX: false)
    
    private var filteredStops: [Stop] {
        stops.filter {
            $0.name.localizedCaseInsensitiveContains(searchQuery)
            || String($0.id).contains(searchQuery)
        }
    }
    // for favorite section
    private var favoritesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Favorite Routes")
                .foregroundColor(.white)
                .font(.title2)
                .padding(.horizontal, 24)
            
            ForEach(stops.flatMap { $0.routeList }
                .filter { favoriteRouteIDs.contains($0.id) }) { route in
                    let parent = stops.first { $0.routeList.contains { $0.id == route.id } }!
                    FavoriteCard(
                        parentStop: parent,
                        route:      route,
                        onRemove:   { favoriteRouteIDs.remove(route.id) }
                    )
                    .padding(.horizontal, 24)
                }
        }
    }
    //for available section
    private var availableSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Available Routes")
                .foregroundColor(.white)
                .font(.title2)
                .padding(.horizontal, 24)
            
            let upcoming = selectedStop.routeList
                .sorted { $0.minutesUntilArrival < $1.minutesUntilArrival && $0.minutesUntilArrival < 60 }
            
            ForEach(upcoming) { route in
                RouteCard(
                    parentStop:  selectedStop,
                    line:        route,
                    isSelected:  route.id == selectedRouteID,
                    onTap:       {
                        if route.id == selectedRouteID {
                            selectedRouteID = nil
                        } else {
                            selectedRouteID = route.id
                        }
                    },
                    isFavorited: favoriteRouteIDs.contains(route.id),
                    toggleFavorite: {
                        if favoriteRouteIDs.contains(route.id) {
                            favoriteRouteIDs.remove(route.id)
                        } else {
                            favoriteRouteIDs.insert(route.id)
                        }
                    }
                )
                .padding(.horizontal, 24)
            }
        }
    }
    
    var body: some View {
        ZStack{
            
            Color.appBackground
                .ignoresSafeArea()
            
            ScrollView (showsIndicators: false) {
                VStack(spacing: 16) {
                    ExtractedLogoAndWelcomeView()
                    //Peep below for extracted structure of searchBar
                    searchBar(
                        searchQuery:  $searchQuery,
                        stopSelected: $stopSelected,
                        selectedStop: $selectedStop,
                        stopList:     filteredStops
                    )
                    if stopSelected {
                        availableSection
                    }
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        //will put the actual favorite routes saved
        HomeView(favoriteRouteIDs: .constant([12, 75]))
            .preferredColorScheme(.dark)
    }
}



struct searchBar: View {
    @Binding var searchQuery: String
    @Binding var stopSelected: Bool
    @Binding var selectedStop: Stop
    var stopList: [Stop]
    
    var body: some View {
        VStack(spacing: 0) { //spacing 0 so that the stop list is seamless
            
            HStack{ //This is the textfield and icon area
                
                TextField("Enter a stop", text: $searchQuery)
                    .submitLabel(.search)
                    .onSubmit { performSearch() }
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .foregroundStyle(Color.black)
                    .autocapitalization(.none)
                    .autocorrectionDisabled(true)
                
                
                
                Image(systemName: "magnifyingglass")
                    .onTapGesture { performSearch() }
                    .foregroundStyle(Color.black)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.gray)
                    .stroke(Color.black)
            )
            .padding(.horizontal, 24)
            .onChange(of: searchQuery) {
                if searchQuery.isEmpty {
                    selectedStop = Stop(id: 0, name: "Placeholder", routeList: [])
                    stopSelected = false
                }
            }
            
            //Below is the logic of the result list
            if !searchQuery.isEmpty && !stopSelected{
                ScrollView {
                    LazyVStack{ //allows for only a set number of stops to be rendered
                        
                        HStack {
                            Text("Use Current Location")
                                .foregroundStyle(Color.black)
                            
                            Spacer()
                            
                            Image(systemName: "location.fill")
                                .foregroundColor(.black)
                        }
                        .padding(12)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white) //Need to add .onTapGesture
                        
                        Divider()
                            .background(Color.gray.opacity(0.6))
                        
                        ForEach(stopList) { stop in
                            Text(stop.name + " (Stop " + stop.id.description + ")")
                                .padding(12)
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundStyle(Color.black)
                                .background(Color.white)
                                .onTapGesture {
                                    searchQuery = stop.name
                                    selectedStop = stop
                                    stopSelected = true
                                }
                            
                            Divider()
                                .background(Color.gray.opacity(0.6))//gives those partitions
                        }
                    }
                }
                .frame(maxHeight: 150)
                .background(Color.white)
                .cornerRadius(8)
                .padding(.horizontal, 24)
                .zIndex(2)
            }
        }
    }
    
    private func performSearch() {
        if let match = stopList.first(where: {
            $0.name.lowercased().hasPrefix(searchQuery.lowercased())
        }) {
            selectedStop = match
            stopSelected  = true
        }
    }
}



struct ExtractedLogoAndWelcomeView: View { //MUST PLACE IN VSTACK
    var body: some View {
        VStack{
            Image("TriLiveLogo") //Logo
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 150, height: 150)
                .padding(.top, 25)
            
            HStack{
                
                Text("Welcome!") //This is the header
                    .font(.system(size: 38, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.leading, 16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
            }
            .padding()
        }
    }
}
