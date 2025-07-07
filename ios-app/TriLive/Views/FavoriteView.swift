//
//  FavoriteView.swift
//  TriLive
//
//  Created by Brian Maina on 6/22/25.
//

//
//  FavoritesView.swift
//  TriLive
//
//  Created by <you> on <date>.
//

import SwiftUI

struct FavoritesView: View {
    // this binds into the same Set<Int> you pass down from MainTabView
    @Binding var favoriteRouteIDs: Set<Int>
    @Binding var navPath: NavigationPath
    let stops: [Stop]
    @ObservedObject var timeManager: TimeManager
    
    
    var favoriteRoutes: [ (stop: Stop, route: Route) ] {
        stops
            .flatMap { stop in stop.routeList.map { (stop, $0) } }
            .filter { favoriteRouteIDs.contains($0.1.id) }
    }
    
    var body: some View {
        NavigationStack (path: $navPath) {
            ZStack {
                
                Color.appBackground.edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        
                        if favoriteRoutes.isEmpty {
                            Text("No Favorites Yet...")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 16)
                        } else {
                            Text("Your Favorites")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 16)
                        }
                        
                        ForEach(favoriteRoutes, id: \.1.id) { pair in
                            NavigationLink(value: pair.route) {
                                FavoriteCard(
                                    parentStop: pair.stop,
                                    route: pair.route,
                                    onRemove:   { favoriteRouteIDs.remove(pair.route.id) }
                                )
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.vertical)
                }
                .navigationTitle("Favorites")
                .navigationDestination(for: Route.self) { route in
                    let stop = stops.first { $0.routeList.contains { $0.id == route.id } }!
                    RouteDetailView(parentStop: stop, route: route, navPath: $navPath, timeManager: timeManager)
                }
            }
        }
    }
}
