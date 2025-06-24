//
//  ContentView.swift
//  TriLive
//
//  Created by Anthony Qin on 6/6/25.
//

import SwiftUI
import UIKit
import Foundation
import CoreLocation

//Location Manager
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    
    @Published var location: CLLocationCoordinate2D?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        location = locations.first?.coordinate
    }
}

//START OF HomeView
/*
 struct HomeView_Previews: PreviewProvider {
 @State static private var previewFavorites: Set<Int> = []
 @State static private var previewNavigationPath = NavigationPath()
 static var previews: some View {
 HomeView(favoriteRouteIDs: $previewFavorites, navigationPath: $previewNavigationPath)
 }
 }*/


struct HomeView: View {
    @Binding var favoriteRouteIDs: Set<Int>
    @ObservedObject var locationManager: LocationManager //for location
    @ObservedObject var timeManager: TimeManager //for progress bar to track time elapsed
    @FocusState private var isTextFieldFocused: Bool //if text field is clicked, then search results show up.
    
    @State private var searchQuery: String = ""
    @State private var stopSelected: Bool = false
    
    @State private var selectedRouteID: Int? = nil
    //for the selected route popping out
    @State private var focusedRoute: Route? = nil
    @Binding var navigationPath: NavigationPath
    
    @State var selectedStop: Stop = Stop(id: 0, name: "Placeholder", routeList: [])
    @State var selectedRoute: Route = Route(id: 0, name: "Placeholder", arrivalTime: 0, direction: "Placeholder", realTime: 0, isMAX: false)
    
    //function for card tap
    private func cardTapped(_ route: Route){
        if focusedRoute == nil {
            focusedRoute = route
        } else {
            //this is whats gonna happen when the user clicks on it, we can make a function that when its selected it calls this and that prompts the start view
            startTracking(route)
            focusedRoute = nil
        }
    }
    
    private func startTracking(_ route: Route){
        navigationPath.append(route)
        print("Now starting route:", route.name)
        timeManager.startTime()
    }
    
    //cancels the blur and goes back to the home view
    private func cancelFocus(){
        focusedRoute = nil
    }
    
    //trying to make the function that blurs the background to focus on the one card
    func blurOverlay(_ route: Route) -> some View{
        ZStack{
            VisualEffectBlur(blurStyle: .systemUltraThinMaterialDark)
                .ignoresSafeArea()
            
            VStack(spacing: 24){
                NavigationLink(value: route){
                    RouteCard(
                        parentStop:  selectedStop,
                        line:        route,
                        isSelected:  route.id == selectedRouteID,
                        onTap: { cardTapped(route) },
                        isFavorited: favoriteRouteIDs.contains(route.id),
                        toggleFavorite: {
                            if favoriteRouteIDs.contains(route.id) {
                                favoriteRouteIDs.remove(route.id)
                            } else {
                                favoriteRouteIDs.insert(route.id)
                            }
                        }
                    )
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(radius: 20)
                .padding(.horizontal, 40)
                
                //to start the route
                Text("Tap the card again to start")
                    .foregroundColor(.white)
                    .font(.headline)
                
                //cancel and go back to home page
                Button("Cancel"){
                    cancelFocus()
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 32)
                .background(Color.white.opacity(0.2))
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding(.bottom, 80)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
    }
    
    
    
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
                .sorted { $0.minutesUntilArrival < $1.minutesUntilArrival}
            //.filter { $0.minutesUntilArrival < 180 }
            
            ForEach(upcoming) { route in
                NavigationLink(value: route){
                    RouteCard(
                        parentStop:  selectedStop,
                        line:        route,
                        isSelected:  route.id == selectedRouteID,
                        onTap: { cardTapped(route) },
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
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack{
                Color.appBackground
                    .ignoresSafeArea()
                    .onTapGesture {
                        isTextFieldFocused = false
                    }
                
                ScrollView (showsIndicators: false) {
                    VStack(spacing: 24) {
                        ExtractedLogoAndWelcomeView()
                        //Peep below for extracted structure of searchBar
                        searchBar(
                            locationManager: locationManager,
                            searchQuery:  $searchQuery,
                            stopSelected: $stopSelected,
                            selectedStop: $selectedStop,
                            stopList:     filteredStops,
                            isTextFieldFocused: $isTextFieldFocused
                        )
                        
                        if stopSelected {
                            availableSection
                                .opacity(isTextFieldFocused ? 0.3 : 1)
                                .allowsHitTesting(!isTextFieldFocused)
                                .blur(radius: isTextFieldFocused ? 5 : 0)
                        }
                    }
                    .padding(.top, 24)
                }
                .navigationDestination(for: Route.self) { route in
                    let stop = stops.first { $0.routeList.contains(route) }!
                    RouteDetailView(parentStop: stop, route: route, navPath: $navigationPath, timeManager: timeManager)
                }
                //when the route card is picked and focused on, it calls blurOverlay and focuses on the selected route
                if let focused = focusedRoute{
                    blurOverlay(focused)
                        .transition(.opacity.animation(.easeInOut(duration: 0.3)))
                }
            }
        }
    }
    
    
    
    
    struct searchBar: View {
        @ObservedObject var locationManager: LocationManager
        @Binding var searchQuery: String
        @Binding var stopSelected: Bool
        @Binding var selectedStop: Stop
        var stopList: [Stop]
        @FocusState.Binding var isTextFieldFocused: Bool
        
        var body: some View {
            VStack(spacing: 0) { //spacing 0 so that the stop list is seamless
                HStack{ //This is the textfield and icon area
                    
                    TextField("Enter a stop", text: $searchQuery)
                        .focused($isTextFieldFocused)
                        .submitLabel(.search)
                        .onSubmit { performSearch() }
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .foregroundStyle(.primary)
                        .autocapitalization(.none)
                        .autocorrectionDisabled(true)
                    
                    
                    
                    Image(systemName: "magnifyingglass")
                        .onTapGesture { performSearch() }
                        .foregroundStyle(.secondary)
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.secondarySystemBackground))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gray)
                        .stroke(Color.black)
                )
                .padding(.horizontal, 24)
                .onChange(of: isTextFieldFocused) {
                    if searchQuery.isEmpty {
                        selectedStop = Stop(id: 0, name: "Placeholder", routeList: [])
                        stopSelected = false
                    }
                }
                .onChange(of: searchQuery) {
                    if searchQuery != selectedStop.name{
                        selectedStop = Stop(id: 0, name: "Placeholder", routeList: [])
                        stopSelected = false
                    }
                }
                
                
                
                
                
                //Below is the logic of the result list
                if (!searchQuery.isEmpty && !stopSelected) || isTextFieldFocused{
                    ScrollView (showsIndicators: false) {
                        LazyVStack (spacing: 0){ //allows for only a set number of stops to be rendered
                            
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
                            .background(Color(.white))
                            .onTapGesture {
                                
                                isTextFieldFocused = false
                                
                                if let location = locationManager.location {
                                    //Use coordinates to find closest stop
                                    //Then, set the stop
                                }
                            }
                            
                            Divider()
                                .background(Color.gray.opacity(0.6))
                            
                            ForEach(stopList) { stop in
                                Text(stop.name + " (Stop " + stop.id.description + ")")
                                    .padding(12)
                                    .foregroundStyle(Color.black)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.white)
                                    .onTapGesture {
                                        isTextFieldFocused = false
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
                    .cornerRadius(8)
                    .padding(.horizontal, 24)
                    .zIndex(2)
                }
            }
        }
        
        private func performSearch() {
            if let match = stopList.first(where: { $0.name.lowercased().hasPrefix(searchQuery.lowercased()) }) {
                selectedStop = match
                stopSelected = true
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
}
