import SwiftUI

struct HomeView: View {
    // MARK: – injected from App entry‐point
    @Binding var favoriteRouteIDs: Set<Int>
    @ObservedObject var locationManager: LocationManager
    @ObservedObject var timeManager: TimeManager
    @Binding var navigationPath: NavigationPath

    // MARK: – search & focus state
    @State private var searchQuery = ""
    @FocusState private var isSearchFocused: Bool

    // MARK: – view model with loading & error state
    @StateObject private var stopVM = StopViewModel()

    // for tap‐to‐highlight behavior
    @State private var focusedRoute: Route?

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()

                // main scrollable content
                ScrollView {
                    VStack(spacing: 24) {
                        ExtractedLogoAndWelcomeView()

                        SearchBar(
                            locationManager: locationManager,
                            searchQuery:     $searchQuery,
                            stopSelected:    Binding(
                                                 get: { stopVM.selectedStop != nil },
                                                 set: { _ in }
                                             ),
                            selectedStop:    $stopVM.selectedStop,
                            stopList:        stopVM.filteredStops,
                            isFocused:       $isSearchFocused
                        )
                        //closure so Swift knows we’re calling StopViewModel.filter(_:)
                        .onChange(of: searchQuery) { newQuery in
                            stopVM.filter(query: newQuery)
                        }
                        .zIndex(1)

                        if let stop = stopVM.selectedStop {
                            ForEach(stop.routeList) { route in
                                RouteCard(
                                    parentStop:    stop,
                                    line:          route,
                                    isSelected:    route.id == focusedRoute?.id,
                                    onTap:         { handleTap(route) },
                                    isFavorited:   favoriteRouteIDs.contains(route.id),
                                    toggleFavorite:{ toggleFavorite(route) }
                                )
                                .padding(.horizontal, 12)
                            }
                        }

                        Spacer()
                    }
                    .padding(.top, 24)
                }

                // overlay spinner when loading
                if stopVM.isLoading {
                    Color.black.opacity(0.25)
                        .ignoresSafeArea()

                    ProgressView("Loading stops…")
                        .padding(16)
                        .background(.regularMaterial)
                        .cornerRadius(8)
                }
            }
            // alert on error
            .alert(
                "Error loading stops",
                isPresented: $stopVM.showError,
                actions: { Button("OK", role: .cancel) {} },
                message: { Text(stopVM.errorMessage ?? "Unknown error") }
            )
            .onAppear {
                stopVM.loadStops()
            }
        }
    }

    // MARK: – actions

    private func handleTap(_ route: Route) {
        if focusedRoute == nil {
            focusedRoute = route
        } else {
            navigationPath.append(route)
            timeManager.startTime()
            focusedRoute = nil
        }
    }

    private func toggleFavorite(_ route: Route) {
        if favoriteRouteIDs.contains(route.id) {
            favoriteRouteIDs.remove(route.id)
        } else {
            favoriteRouteIDs.insert(route.id)
        }
    }
}
