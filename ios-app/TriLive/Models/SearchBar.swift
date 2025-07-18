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
                
                Spacer()

                Image(systemName: "magnifyingglass")
                    .padding(.horizontal, 16)
                    .onTapGesture { performSearch() }
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.secondarySystemBackground))
            )
            .foregroundColor(.primary)
            .padding(.horizontal)
            .onChange(of: searchQuery) { _ in
                // break concatenation into vars
                let baseName = selectedStop?.name ?? ""
                let baseDir  = selectedStop?.dir  ?? ""
                let expected = baseName + " " + dirMapper(baseDir)
                if searchQuery != expected {
                    stopSelected  = false
                    selectedStop  = nil
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
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(.primary)
                        .background(Color(.systemBackground))
                        .onTapGesture {
                            stopSelected = false
                            selectedStop = nil
                            selectNearestStop()
                            isFocused = false
                        }
                        Divider()

                        ForEach(stopList) { stop in
                            // pull this string out
                            let baseDir = stop.dir ?? ""
                            let label   = stop.name + " " + dirMapper(baseDir)
                            Text(label)
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
        let rawQuery = searchQuery
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        guard !rawQuery.isEmpty else { return }

        let ampVariant = rawQuery.replacingOccurrences(of: "and", with: "&")
        let andVariant = rawQuery.replacingOccurrences(of: "&",   with: "and")
        let variants   = [rawQuery, ampVariant, andVariant]

        if let match = stopList.first(where: { stop in
            let nameLower = (stop.name + " " + (stop.dir ?? "")).lowercased()
            let idLower   = String(describing: stop.id).lowercased()

            // explicit loop instead of nested contains calls
            for q in variants {
                if nameLower.contains(q)
                    || idLower.hasPrefix(q)
                    || idLower.contains(q)
                {
                    return true
                }
            }
            return false
        }) {
            select(match)
        }
    }

    //When a stop row is tapped
    private func select(_ stop: Stop) {
        let baseName = stop.name
        let baseDir  = stop.dir ?? ""
        let combined = baseName + " " + dirMapper(baseDir)
        
        searchQuery  = combined
        selectedStop = stop
        stopSelected = true
        isFocused    = false
    }
    // creates shorthand for direction labels
    private func dirMapper(_ dir: String) -> String {
        switch dir {
        case "Northbound": return "N"
        case "Southbound": return "S"
        case "Eastbound":  return "E"
        case "Westbound":  return "W"
        default:           return ""
        }
    }

    private func selectNearestStop() {
        // grabs the user’s coordinate
        guard let coord = locationManager.location else { return }
        // wraps it in a CLLocation so we can measure distance
        let userLoc = CLLocation(latitude: coord.latitude,
                                longitude: coord.longitude)

        // finds the nearest stop by comparing distances
        guard let nearest = stopList.min(by: { s1, s2 in
            let loc1 = CLLocation(latitude: s1.lat, longitude: s1.lon)
            let loc2 = CLLocation(latitude: s2.lat, longitude: s2.lon)
            return userLoc.distance(from: loc1) < userLoc.distance(from: loc2)
        }) else { return }

        // selects it
        let nearestDir = nearest.dir ?? ""
        searchQuery  = nearest.name + " " + dirMapper(nearestDir)
        selectedStop = nearest
        stopSelected = true
        isFocused    = false
    }
}
