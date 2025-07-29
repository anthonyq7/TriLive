import Foundation
// model for a transit stop
struct Stop: Codable, Identifiable, Equatable {
    // these map cleanly from snake_case via .convertFromSnakeCase
    let stopId:     Int
    let name:       String
    let dir:        String?       // your JSON always has "dir"
    let lon:        Double        // from "lon"
    let lat:        Double        // from "lat"
    let dist:       Int           // from "dist"
    let description: String?      // from "description" (nullable)
    
    // satisfy Identifiable
    var id: Int { stopId }
}


// model for a route arrival entry
struct Route: Codable, Hashable, Identifiable {
    let stopId:     Int
    let routeId:    Int
    let routeName:  String
    let status:     String
    let eta:        String
    let routeColor: String
    let eta_unix:   Int
    let vehicleId: Int
    
    var id: Int { routeId }
}
// model for a favorite route entry
struct Favorite: Identifiable, Codable, Hashable {
    var id: UUID = .init()
    let parentStopName: String
    let stopId: Int
    let route: Route
}

// store for managing favorites in UserDefaults
class FavoritesStore: ObservableObject {
    @Published private(set) var items: [Favorite] = []
    
    // creates key for UserDefaults storage
    private let key = "favoriteRoutesData"
    
    init() {
        if
            let data = UserDefaults.standard.data(forKey: key),
            let decoded = try? JSONDecoder().decode([Favorite].self, from: data)
        {
            items = decoded
        }
    }
    
    // adds or removes favorite, then saves
    func toggle(_ fav: Favorite) {
        if let idx = items.firstIndex(of: fav) {
            items.remove(at: idx)
        } else {
            items.append(fav)
        }
        save()
    }
    
    // encodes items as JSON and writes to UserDefaults
    private func save() {
        if let data = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    func contains(_ fav: Favorite) -> Bool {
        // returns whether a favorite is already in the store
        items.contains(fav)
    }
}

