import Foundation

struct Stop: Identifiable, Decodable, Hashable {
  let id:   Int
  let name: String
  let lon:  Double
  let lat:  Double
}


struct Route: Identifiable, Codable, Hashable {
    let stopId: Int
    let routeId: Int
    let routeName: String
    let status: String
    let eta: String
    let routeColor: String

    var id: Int { routeId }
}
