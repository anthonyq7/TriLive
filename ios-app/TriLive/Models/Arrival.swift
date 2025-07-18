import Foundation

struct Arrival: Identifiable, Decodable, Equatable {
  let id = UUID()
  let routeId:    Int
  let routeName:  String
  let status:     String
  let eta:        Int
  let routeColor: String

  enum CodingKeys: String, CodingKey {
    case routeId    = "route_id"
    case routeName  = "route_name"
    case status
    case eta
    case routeColor = "route_color"
  }
    
  var arrivalDate: Date {
    Date(timeIntervalSince1970: Double(eta) / 1_000)
  }
    
  var minutesUntilArrival: Int {
    let diff = arrivalDate.timeIntervalSinceNow
    return max(0, Int(diff / 60))
  }
}

