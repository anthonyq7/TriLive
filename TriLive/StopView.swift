//
//  StopView.swift
//  TriLive
//
//  Created by Anthony Qin on 6/14/25.
//

//DO NOT USE FOR NOW (EXPERIMENTING)
import SwiftUI

struct StopListView: View {

    @State private var searchQuery = ""

    let allStops: [Stop] = [
        Stop(id: 258, name: "Hawthorne & 12th"),
        Stop(id: 259, name: "Hawthorne & 14th"),
        Stop(id: 310, name: "Main & 1st"),
        Stop(id: 311, name: "Division & 10th")
    ]

    var filteredStops: [Stop] {
        if searchQuery.isEmpty {
            return allStops
        } else {
            return allStops.filter {
                $0.name.localizedCaseInsensitiveContains(searchQuery)
            }
        }
    }

    var body: some View {
        NavigationView {
            List(filteredStops) { stop in
                NavigationLink(destination: StopDetailView(stop: stop)) {
                    Text("\(stop.name) (Stop \(stop.id))")
                }
            }
            .navigationTitle("Find a Stop")
            .searchable(text: $searchQuery, placement: .navigationBarDrawer(displayMode: .always))
        }
    }
}

struct StopDetailView: View {
    let stop: Stop

    var body: some View {
        Text("Details for \(stop.name) (ID \(stop.id))")
            .navigationTitle(stop.name)
    }
}

#Preview {
    StopListView()
}

