import SwiftUI
import CoreLocation

struct SearchBar: View {
    @ObservedObject var locationManager: LocationManager
    @Binding var searchQuery: String
    @Binding var stopSelected: Bool
    @Binding var selectedStop: Stop?
    var stopList: [Stop]
    @FocusState.Binding var isFocused: Bool

    @State private var lastQuery: String = ""
    @State private var showSuggestions: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            // Main search field
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search stops", text: $searchQuery)
                    .focused($isFocused)
                    .submitLabel(.search)
                    .onSubmit(performSearch)
                    .onChange(of: searchQuery, perform: onQueryChange)
                    .foregroundColor(.primary)
                if !searchQuery.isEmpty {
                    Button(action: clear) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity)
            .background(Color("SearchBarBackground"))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 2)
            .padding(.horizontal, 12)
            .zIndex(1)

            if isFocused && showSuggestions && !stopList.isEmpty {
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        suggestionRow(label: "Use Current Location") { selectNearestStop() }
                        ForEach(stopList) { stop in
                            let label = stop.name + " " + dirMapper(stop.dir ?? "")
                            suggestionRow(label: label) { select(stop) }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: 220)
                .background(Color("SearchResultsBackground"))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 2)
                .padding(.horizontal, 12)
            }
        }
    }

    private func onQueryChange(_ newValue: String) {
        showSuggestions = newValue.count > 0 || (stopSelected && newValue.count < lastQuery.count)
        lastQuery = newValue
        let expected = (selectedStop?.name ?? "") + " " + dirMapper(selectedStop?.dir ?? "")
        if newValue != expected {
            stopSelected = false
            selectedStop = nil
        }
    }

    @ViewBuilder
    private func suggestionRow(label: String, action: @escaping () -> Void) -> some View {
        Button(action: { action(); isFocused = false; showSuggestions = false }) {
            HStack {
                Text(label)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                Spacer()
                if label == "Use Current Location" {
                    Image(systemName: "location.fill")
                        .foregroundColor(Color("AccentColor"))
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity)
        }
        Divider().background(Color.white.opacity(0.2))
    }

    private func clear() {
        searchQuery = ""; stopSelected = false; selectedStop = nil; showSuggestions = false
    }

    private func performSearch() {
        let raw = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !raw.isEmpty else { showSuggestions = false; return }
        let variants = [raw, raw.replacingOccurrences(of: "and", with: "&"), raw.replacingOccurrences(of: "&", with: "and")]
        if let match = stopList.first(where: { stop in
            let full = (stop.name + " " + (stop.dir ?? "")).lowercased()
            return variants.contains { full.contains($0) }
        }) {
            select(match)
        }
        showSuggestions = false
    }

    private func select(_ stop: Stop) {
        searchQuery = stop.name + " " + dirMapper(stop.dir ?? "")
        selectedStop = stop; stopSelected = true; showSuggestions = false
    }

    private func dirMapper(_ dir: String) -> String {
        switch dir {
        case "Northbound": return "N"; case "Southbound": return "S"
        case "Eastbound":  return "E"; case "Westbound":  return "W"
        default:            return ""
        }
    }

    private func selectNearestStop() {
        guard let coord = locationManager.location else { return }
        let userLoc = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
        if let nearest = stopList.min(by: { s1, s2 in
            let l1 = CLLocation(latitude: s1.lat, longitude: s1.lon)
            let l2 = CLLocation(latitude: s2.lat, longitude: s2.lon)
            return userLoc.distance(from: l1) < userLoc.distance(from: l2)
        }) {
            select(nearest)
        }
    }
}
