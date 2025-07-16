import SwiftUI
import CoreLocation

struct SearchBar: View {
    @ObservedObject var locationManager: LocationManager
    @Binding var searchQuery: String
    @Binding var stopSelected: Bool
    @Binding var selectedStop: Stop?
    var stopList: [Stop]
    @FocusState.Binding var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            //Text field + search icon
            HStack {
                TextField("Enter a stop", text: $searchQuery)
                    .focused($isFocused)
                    .submitLabel(.search)
                    .onSubmit(performSearch)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.secondarySystemBackground))
                    )
                    .foregroundColor(.primary)

                Image(systemName: "magnifyingglass")
                    .padding(.horizontal, 16)
                    .onTapGesture { performSearch() }
            }
            .padding(.horizontal)
            .onChange(of: searchQuery){
                if searchQuery != selectedStop?.name {
                    stopSelected = false
                    selectedStop = nil
                }
            }

            //Dropdown
            if isFocused && !stopList.isEmpty {
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 0) {

                        HStack {
                            Text("Use Current Location")
                            Spacer()
                            Image(systemName: "location.fill")
                        }
                        .padding(12)
                        .foregroundColor(.primary)
                        .background(Color(.systemBackground))
                        .onTapGesture {
                            isFocused = false
                            selectNearestStop()
                        }
                        Divider()


                        ForEach(stopList) { stop in
                            Text(stop.name)
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.primary)
                                .background(Color(.systemBackground))
                                .onTapGesture {
                                    select(stop)
                                    isFocused = false
                                }
                            Divider()
                        }
                    }
                }
                .frame(maxHeight: 250)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                .shadow(radius: 4)
                .padding(.horizontal)
                .zIndex(1)
            }
        }
    }

    //Tap the magnifying glass or hit return
    private func performSearch() {
        if let match = stopList.first(where: {
            $0.name.localizedCaseInsensitiveContains(searchQuery) ||
            "\($0.id)".hasPrefix(searchQuery)
        }) {
            select(match)
        }
    }

    //When a stop row is tapped
    private func select(_ stop: Stop) {
        searchQuery   = stop.name
        selectedStop  = stop
        stopSelected  = true
        isFocused = false
    }


    private func selectNearestStop() {
        //grabs the user’s coordinate
        guard let coord = locationManager.location else { return }
        //wraps it in a CLLocation so we can measure distance
        let userLoc = CLLocation(latitude: coord.latitude,
                                 longitude: coord.longitude)

        //finds the nearest stop by comparing distances
        guard let nearest = stopList.min(by: { s1, s2 in
            let loc1 = CLLocation(latitude: s1.lat, longitude: s1.lon)
            let loc2 = CLLocation(latitude: s2.lat, longitude: s2.lon)
            return userLoc.distance(from: loc1) < userLoc.distance(from: loc2)
        }) else { return }

        //selects it
        searchQuery   = nearest.name
        selectedStop  = nearest
        stopSelected  = true
        isFocused = false
    }
}
