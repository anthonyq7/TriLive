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


    private var favoriteRoutes: [Route] {
        stops
            .flatMap { $0.routeList }
            .filter { favoriteRouteIDs.contains($0.id) }
    }

    var body: some View {
        NavigationView {
            ZStack {
                
                Color.appBackground.edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    LazyVStack {
                
                        ForEach(favoriteRoutes) { route in
                            
                            let parent = stops.first {
                                $0.routeList.contains { $0.id == route.id }
                            }!
                            
                            FavoriteCard(
                                parentStop: parent,
                                route:      route,
                                onRemove: {favoriteRouteIDs.remove(route.id)}
                            )
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets())
                            .padding(.horizontal, 16)
                        }
                        .padding(.top, 16)
                        
                        Spacer()
                    }
                }
            }
            .navigationTitle("Favorite Routes")
        }
    }
}

struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesView(
          favoriteRouteIDs: .constant([12, 1]),
          stops: stops
        )
        .preferredColorScheme(.dark)
    }
}
