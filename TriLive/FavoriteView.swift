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
    let stops: [Stop]


    var favoriteRoutes: [ (stop: Stop, route: Route) ] {
       stops
         .flatMap { stop in stop.routeList.map { (stop, $0) } }
         .filter { favoriteRouteIDs.contains($0.1.id) }
     }

     var body: some View {
       NavigationStack {
         ScrollView {
           VStack(alignment: .leading, spacing: 16) {
             Text("Your Favorites")
               .font(.title2)
               .fontWeight(.semibold)
               .padding(.horizontal)

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
           RouteDetailView(parentStop: stop, route: route)
         }
       }
     }
   }
