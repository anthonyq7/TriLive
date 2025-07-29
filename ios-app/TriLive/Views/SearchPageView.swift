import SwiftUI
import CoreLocation

struct SearchPageView: View {
    @Binding var searchQuery: String
    @Binding var selectedStop: Stop?
    @Binding var showSearchPage: Bool
    
    @ObservedObject var locationManager: LocationManager
    var stopList: [Stop]
    let namespace: Namespace.ID
    
    @State private var showSuggestions: Bool = false
    @State private var lastQuery: String = ""
    @FocusState private var isFocused: Bool
    
    private var matchedStops: [Stop] {
        let raw = searchQuery
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        guard !raw.isEmpty else { return [] }
        let variants = [ raw,
                         raw.replacingOccurrences(of: "and", with: "&"),
                         raw.replacingOccurrences(of: "&", with: "and") ]
        return stopList.filter { stop in
            let full = (stop.name + " " + (stop.dir ?? "")).lowercased()
            let nameMatches = variants.contains { full.contains($0) }
            
            let numberString = String(stop.id)
            let numberMatches = numberString.contains(raw)
            
            return nameMatches || numberMatches
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search stops", text: $searchQuery)
                        .focused($isFocused)
                        .submitLabel(.search)
                        .onChange(of: searchQuery) { onQueryChange($0) }
                        .onSubmit { performSearch() }
                    Spacer()
                    if !searchQuery.isEmpty {
                        Button(action: {searchQuery = ""}) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                        .animation(.easeInOut(duration: 0.5), value: searchQuery)
                    }
                }
                .padding(.vertical, 14)
                .padding(.horizontal, 20)
                .background(Color("SearchBarBackground"))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 2)
                .matchedGeometryEffect(id: "searchBar", in: namespace)
                
                Button(action: { withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { showSearchPage = false } }) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .padding(.leading, 8)
                }
            }
            .padding()
            
            if showSuggestions {
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        Button(action: { selectNearestStop(); withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { showSearchPage = false } }) {
                            suggestionRow(label: "Use Current Location", icon: "location.fill")
                        }
                        if matchedStops.isEmpty {
                            Text("No results")
                                .foregroundColor(.secondary)
                                .padding()
                        } else {
                            ForEach(matchedStops) { stop in
                                let label = stop.name + " " + dirMapper(stop.dir ?? "")
                                Button(action: { select(stop); withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { showSearchPage = false } }) {
                                    suggestionRow(label: label, icon: nil)
                                }
                            }
                        }
                    }
                }
                .background(Color("SearchResultsBackground"))
            } else {
                Spacer()
            }
        }
        .background(Color("AppBackground").ignoresSafeArea())
        .onAppear { isFocused = true; showSuggestions = !searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }
    
    @ViewBuilder
    private func suggestionRow(label: String, icon: String?) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text(label)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                Spacer()
                if let icon = icon {
                    Image(systemName: icon)
                        .foregroundColor(Color("AccentColor"))
                }
            }
            .padding(12)
            Divider()
                .background(Color.white.opacity(0.2))
        }
    }
    
    private func onQueryChange(_ newValue: String) {
        let trimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
        // clear selected stop if query emptied or changed
        if trimmed.isEmpty {
            selectedStop = nil
        }
        showSuggestions = !trimmed.isEmpty || trimmed.count < lastQuery.count
        lastQuery = trimmed
    }
    
    private func performSearch() { onQueryChange(searchQuery) }
    
    private func select(_ stop: Stop) { searchQuery = stop.name + " " + dirMapper(stop.dir ?? ""); selectedStop = stop; showSuggestions = false }
    
    private func selectNearestStop() {
        guard let coord = locationManager.location else { return }
        let userLoc = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
        if let nearest = stopList.min(by: { a, b in
            CLLocation(latitude: a.lat, longitude: a.lon).distance(from: userLoc) < CLLocation(latitude: b.lat, longitude: b.lon).distance(from: userLoc)
        }) {
            select(nearest)
        }
    }
    
    private func dirMapper(_ dir: String) -> String {
        switch dir {
        case "Northbound": return "N"
        case "Southbound": return "S"
        case "Eastbound":  return "E"
        case "Westbound":  return "W"
        default:            return ""
        }
    }
}
