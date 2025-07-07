import SwiftUI
import CoreLocation

struct SearchBar: View {
    @ObservedObject var locationManager: LocationManager
    // observed object to get user location updates
    
    @Binding var searchQuery: String
    // two-way binding for the text field content
    
    @Binding var stopSelected: Bool
    // binding flag to know if a stop has been selected
    
    @Binding var selectedStop: Stop?
    // binding to the currently selected stop
    
    var stopList: [Stop]
    // list of stops to search through
    
    var isFocused: FocusState<Bool>.Binding
    // binding to track whether the text field is focused
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                TextField("Enter a stop", text: $searchQuery)
                    .focused(isFocused)
                    .submitLabel(.search)
                    .onSubmit(performSearch)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.secondarySystemBackground))
                    )
                
                Image(systemName: "magnifyingglass")
                    .onTapGesture { performSearch() }
                    .padding(.horizontal, 24)
                    .onChange(of: searchQuery) { new in
                        // clear selection if query no longer matches selected stop. it says there's a problem with the ios 17 compatability but idk how it works exactly - 'onChange(of:perform:)' was deprecated in iOS 17.0: Use `onChange` with a two or zero parameter action closure instead.
                        if new != selectedStop?.name {
                            selectedStop = nil
                            stopSelected = false
                        }
                    }
                
                if isFocused.wrappedValue {
                    // show suggestions only when focused
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 0) {
                            HStack {
                                Text("Use Current Location")
                                Spacer()
                                Image(systemName: "location.fill")
                            }
                            .padding(12)
                            .background(Color.white)
                            .onTapGesture {
                                isFocused.wrappedValue = false
                            }
                            Divider()
                            
                            ForEach(stopList) { stop in
                                Text("\(stop.name) (Stop \(stop.id))")
                                    .padding(12)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.white)
                                    .onTapGesture {
                                        select(stop)
                                    }
                                Divider()
                            }
                        }
                    }
                    .frame(maxHeight: 250)
                    .cornerRadius(8)
                    .padding(.horizontal, 24)
                    .zIndex(1)
                }
            }
        }
    }
    
    //private helper to find and select a matching stop
    private func performSearch() {
        if let match = stopList.first(where: {
            $0.name.localizedCaseInsensitiveContains(searchQuery)
            || "\($0.id)".hasPrefix(searchQuery)
        }) {
            select(match)
        }
    }
    
    //private helper to update bindings when a stop is chosen
    private func select(_ stop: Stop) {
        searchQuery = stop.name
        selectedStop = stop
        stopSelected = true
        isFocused.wrappedValue = false
    }
}
