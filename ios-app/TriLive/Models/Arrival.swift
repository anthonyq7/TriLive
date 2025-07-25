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
    // converts eta (ms) to a Date object
    Date(timeIntervalSince1970: Double(eta) / 1_000)
  }
    
  var minutesUntilArrival: Int {
    // calculates minutes from now until arrival, non-negative
    let diff = arrivalDate.timeIntervalSinceNow
    return max(0, Int(diff / 60))
  }
}

