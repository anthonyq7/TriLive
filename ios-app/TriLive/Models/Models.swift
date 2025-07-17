import Foundation

struct Stop: Identifiable, Decodable, Hashable {
    let id:   Int
    let name: String
    let lon:  Double
    let lat:  Double
    let dir: String
}


struct Route: Identifiable, Codable, Hashable {
    let stopId: Int
    let routeId: Int
    let routeName: String
    let status: String
    let eta: String
    let routeColor: String
    let eta_unix: Int
    
    var id: Int { routeId }
}
