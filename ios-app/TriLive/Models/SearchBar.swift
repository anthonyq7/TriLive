import SwiftUI
import CoreLocation

struct SearchBar: View {
    @ObservedObject var locationManager: LocationManager
    @Binding var searchQuery: String
    @Binding var stopSelected: Bool
    @Binding var selectedStop: Stop?
    var stopList: [Stop]
    var isFocused: FocusState<Bool>.Binding

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
                    .foregroundColor(.primary)

                Image(systemName: "magnifyingglass")
                    .padding(.horizontal, 16)
                    .onTapGesture { performSearch() }
            }
            .padding(.horizontal)

            // dropdown only when focused and we have results
            if isFocused.wrappedValue && !stopList.isEmpty {
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        // current-location row
                        HStack {
                            Text("Use Current Location")
                            Spacer()
                            Image(systemName: "location.fill")
                        }
                        .padding(12)
                        .foregroundColor(.primary)
                        .background(Color(.systemBackground))
                        .onTapGesture {
                            isFocused.wrappedValue = false
                            // handle actual location pick…
                        }
                        Divider()

                        // your stops
                        ForEach(stopList) { stop in
                            Text(stop.name)
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.primary)
                                .background(Color(.systemBackground))
                                .onTapGesture { select(stop) }
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

    private func performSearch() {
        if let match = stopList.first(where: {
            $0.name.localizedCaseInsensitiveContains(searchQuery)
            || "\($0.id)".hasPrefix(searchQuery)
        }) {
            select(match)
        }
    }

    private func select(_ stop: Stop) {
        searchQuery = stop.name
        selectedStop  = stop
        stopSelected  = true
        isFocused.wrappedValue = false
    }
}
