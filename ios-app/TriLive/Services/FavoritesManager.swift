// FavoritesManager.swift

import Foundation
import Combine

@MainActor
final class FavoritesManager: ObservableObject {
    @Published var favoriteRouteIDs: Set<Int> = []
  @Published var routes: [Route] = [] {
    didSet { save() }
  }

  private let key = "favoriteRoutes"

  init() {
    if
      let data = UserDefaults.standard.data(forKey: key),
      let decoded = try? JSONDecoder().decode([Route].self, from: data)
    {
      routes = decoded
    }
  }

  func toggle(_ route: Route) {
    if let idx = routes.firstIndex(where: {
      $0.stopId == route.stopId && $0.routeId == route.routeId
    }) {
      routes.remove(at: idx)
    } else {
      routes.append(route)
    }
  }

  private func save() {
    if let data = try? JSONEncoder().encode(routes) {
      UserDefaults.standard.set(data, forKey: key)
    }
  }
}
